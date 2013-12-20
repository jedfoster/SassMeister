$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'rubygems'
require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/partial'
require 'chairman'
require 'json'
require 'sass'
require 'compass'
require 'yaml'
require 'sassmeister'

# require 'pry-remote'

class SassMeisterApp < Sinatra::Base
  register Sinatra::Partial

  use Chairman::Routes

  helpers SassMeister

  configure do
    APP_VERSION = '2.0.1'
  end

  # implement redirects
  class Chairman::Routes
    configure :production do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.com',
                                   :domain => '.sassmeister.com',
                                   :path => '/',
                                   :expire_after => 7776000, # 90 days, in seconds
                                   :secret => ENV['COOKIE_SECRET']
       end
    end

    configure :development do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.dev',
                                   :path => '/',
                                   :expire_after => 7776000, # 90 days, in seconds
                                   :secret => 'local'
      end
    end

    after '/authorize/return' do
      session[:version] == SassMeisterApp::APP_VERSION

      redirect to('/')
    end

    after '/logout' do
      redirect to('/')
    end
  end

  set :partial_template_engine, :erb

  configure :production do
    APP_DOMAIN = 'sassmeister.com'
    SANDBOX_DOMAIN = 'sandbox.sassmeister.com'
    require 'newrelic_rpm'

    Chairman.config(ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist'])
  end

  configure :development do
    APP_DOMAIN = 'sassmeister.dev'
    SANDBOX_DOMAIN = 'sandbox.sassmeister.dev'
    yml = YAML.load_file("config/github.yml")
    Chairman.config(yml["client_id"], yml["client_secret"], ['gist'])
  end

  helpers do
    def origin
      return request.env["HTTP_ORIGIN"] if origin_allowed? request.env["HTTP_ORIGIN"]

      return false
    end

    def origin_allowed?(uri)
      return false if uri.nil?

      return uri.match(/^http:\/\/(.+\.){0,1}sassmeister\.(com|dev|([\d+\.]{4}xip\.io))/)
    end
  end


  before do
    @github = Chairman.session(session[:github_token])
    @gist = nil
    @plugins = plugins

    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?

    headers 'Access-Control-Allow-Origin' => origin if origin
  end

  before /^(?!\/(authorize))/ do
    if session[:version].nil? || session[:version] != APP_VERSION
      session[:github_token] = nil
      session[:github_id] = nil
      @force_invalidate = true
      session[:version] = APP_VERSION
    end
  end

  get '/' do
    # if ! params.keys.grep(/(extension|syntax|output)/).empty?
    #   extension = params[:extension].split(',') || []
    #   syntax = (params[:syntax].downcase rescue 'scss')
    #   output = (params[:output].downcase rescue 'expanded')
    #   sass = ''
    #
    #   plugins.each do |key, plugin|
    #     if ! extension.grep(/#{plugin[:fingerprint].gsub(/\*/, '.*?')}/i).empty?
    #       require plugin[:gem]
    #
    #       imports = []
    #       plugin[:import].each do |import|
    #         imports << "@import \"#{import}\""
    #       end
    #
    #       sass += imports.join("#{syntax == 'scss' ? ';' : ''}\n") + "#{syntax == 'scss' ? ';' : ''}\n" unless imports.nil?
    #     end
    #   end
    #
    #   @gist = {
    #     :sass => sass,
    #     :syntax => syntax,
    #     :output => output
    #   }.to_json
    # end

    erb :index, locals: {body_class: false}
  end


  post '/compile' do
    content_type 'application/json'

    {
      css: sass_compile(params[:input], params[:syntax], params[:output_style]),
      dependencies: get_build_dependencies(params[:input])
    }.to_json.to_s
  end


  post '/convert' do
    content_type 'application/json'

    {
      css: sass_convert(params[:original_syntax], params[:syntax], params[:input]),
      dependencies: get_build_dependencies(params[:input])
    }.to_json.to_s    
  end


  get '/thankyou' do
    erb :thankyou, locals: {body_class: 'thankyou'}
  end


  get '/about' do
    erb :about, locals: {body_class: 'about'}
  end


  get '/extensions' do
    erb :extensions, layout: false
  end


  get %r{/gist(?:/[\w]*)*/([\d\w]+)} do
    id = params[:captures].first

    begin
      response = @github.gist(id)

      # For now, we only return the first .sass or .scss file we find.
      file = response.files["#{response.files._fields.grep(/.+\.(scss|sass)/i)[0]}"]

      if( ! file)
        syntax = filename = owner = ''
        sass = "// Sorry, I couldn't find any valid Sass in that Gist."

      else
        sass = file.content
        filename = file.filename
        owner = (response.respond_to?(:user) ? response.user.login : nil)

        syntax = file.filename.slice(-4, 4)
      end

      html_file = response.files["#{response.files._fields.grep(/.+\.(haml|textile|markdown|md|html)/)[0]}"]

      if(html_file)
        html = html_file.content
        html_filename = html_file.filename

        html_syntax = html_file.filename.split('.').pop
        html_syntax = 'markdown' if html_syntax == 'md'

        html_syntax.capitalize!
      end

    rescue Octokit::NotFound => e
      status 404

      syntax = plugin = ''
      sass = "// Sorry, that Gist doesn't exist.\n//#{e.to_s.gsub(/(GET|api.|https:\/\/|\?.*$)/, '')}"
    end

    @gist = {
      :gist_id => id,
      :gist_owner => owner,
      :can_update_gist => (owner == session[:github_id]),
      :sass_filename => filename,
      :html_filename => (html_filename || ''),
      :sass => {
        :input => sass,
        :syntax => syntax,
        :original_syntax => syntax,
        :dependencies => get_frontmatter_dependencies(sass)
      },
      :html => {
        :input => (html || ''),
        :syntax => (html_syntax || ''),
      }
    }.to_json

    erb :index, locals: {body_class: false}
  end


  post '/gist/create' do
    inputs = params[:inputs]
    outputs = params[:outputs]

    sass = inputs[:sass][:input]

    dependencies = pack_dependencies(sass, inputs[:sass][:dependencies])

    css = outputs[:css]

    description = "Generated by SassMeister.com."

    sass_file = "SassMeister-input.#{inputs[:sass][:syntax].downcase}"
    css_file = "SassMeister-output.css"

    html = {}

    if inputs[:html] && inputs[:html][:input].chomp != ''
      html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      html_input = inputs[:html][:input]
      rendered_file = "SassMeister-rendered.html"
      html_output = outputs[:html]

      html = {
        html_file => {
          content: "#{html_input}"
        },
        rendered_file => {
          content: "#{html_output}"
        }
      }
    end

    data = @github.create_gist(description: description, public: true, files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    }.merge(html))

    content_type 'application/json'

    {
      id: data.id,
      sass_filename: sass_file,
      html_filename: html_file
    }.to_json.to_s
  end


  post %r{/gist(?:/[\w]*)*/([\d]+)/edit} do
    id = params[:captures].shift

    inputs = params[:inputs]
    outputs = params[:outputs]

    sass = inputs[:sass][:input]

    dependencies = pack_dependencies(sass, inputs[:sass][:dependencies])

    css = outputs[:css]

    deleted_files = {}

    if inputs[:sass_filename].slice(-4, 4) == inputs[:sass][:syntax].downcase
      sass_file = inputs[:sass_filename]
    else
      sass_file = "#{inputs[:sass_filename].slice(0..-5)}#{inputs[:sass][:syntax].downcase}"
      deleted_files = {inputs[:sass_filename] => {content: nil}}
    end

    css_file = "SassMeister-output.css"

    html = {}

    if inputs[:html] && inputs[:html][:input].chomp != ''
      html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      html_input = inputs[:html][:input]
      rendered_file = "SassMeister-rendered.html"
      html_output = outputs[:html]

      deleted_html = {}

      if inputs[:html_filename] == ''
        html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      elsif inputs[:html_filename].split('.').last == inputs[:html][:syntax].downcase
        html_file = inputs[:html_filename]
      else
        filename = inputs[:html_filename].split('.')
        filename.pop
        filename = filename.join('.')

        html_file = "#{filename}.#{inputs[:html][:syntax].downcase}"
        deleted_html = {inputs[:html_filename] => {content: nil}}
      end

      html = {
        html_file => {
          content: "#{html_input}"
        },
        rendered_file => {
          content: "#{html_output}"
        }
      }.merge(deleted_html)
    end

    data = @github.edit_gist(id, files: {
      css_file => {
        content: "#{css}"
      },
      sass_file => {
        content: "#{dependencies}\n\n#{sass}"
      }
    }.merge(deleted_files).merge(html))

    content_type 'application/json'

    {
      id: data.id,
      sass_filename: sass_file,
      html_filename: html_file
    }.to_json.to_s
  end

  post %r{/gist(?:/[\w]*)*/([\d]+)/fork} do
    id = params[:captures].shift

    data = @github.fork_gist(id)

    content_type 'application/json'

    { id: data.id }.to_json.to_s
  end

  run! if app_file == $0
end
