$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'rubygems'

# If you're using bundler, you will need to add this
require 'bundler/setup'

require 'sinatra/base'
require 'sinatra/partial'
require 'github_api'
require 'chairman'
require 'json'

require 'sass'
require 'compass'
require 'yaml'

require 'sassmeister'
require 'array'

class SassMeisterApp < Sinatra::Base
  register Sinatra::Partial

  use Chairman::Routes

  helpers SassMeister

  # implement redirects
  class Chairman::Routes
    configure :production do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.com',
                                   :domain => :all,
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

    Chairman.config(ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist', 'user'])
  end

  configure :development do
    APP_DOMAIN = 'sassmeister.dev'
    SANDBOX_DOMAIN = 'sandbox.sassmeister.dev'
    yml = YAML.load_file("config/github.yml")
    Chairman.config(yml["client_id"], yml["client_secret"], ['gist', 'user'])
  end


  before do
    @github = Chairman.session(session[:github_token])
    @gist = nil
    @plugins = plugins

    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?
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

    erb :index, locals: {body_class: ''}
  end


  post '/compile' do
    sass_compile(params[:input], params[:syntax], params[:output_style])
  end


  post '/convert' do
    sass_convert(params[:original_syntax], params[:syntax], params[:input])
  end


  get '/thankyou' do
    erb :thankyou, locals: {body_class: 'thankyou'}
  end


  get '/about' do
    erb :about, locals: {body_class: 'about'}
  end


  get %r{/gist(?:/[\w]*)*/([\d]+)} do
    id = params[:captures].first

    begin
      response = Github::Gists.new.get(id, client_id: Chairman.client_id, client_secret: Chairman.client_secret)

      # For now, we only return the first .sass or .scss file we find.
      file = response.files["#{response.files.keys.grep(/.+\.(scss|sass)/i)[0]}"]

      if( ! file)
        syntax = filename = owner = ''
        sass = "// Sorry, I couldn't find any valid Sass in that Gist."

      else
        sass = file.content
        filename = file.filename
        owner = (response.respond_to?(:owner) ? response.owner.login : '')

        syntax = file.filename.slice(-4, 4)
      end


      html_file = response.files["#{response.files.keys.grep(/.+\.(haml|textile|markdown|md|html)/)[0]}"]

      if(html_file)
        html = html_file.content
        html_filename = html_file.filename

        html_syntax = html_file.filename.split('.').pop
        html_syntax = 'markdown' if html_syntax == 'md'

        html_syntax.capitalize!
      end

    rescue Github::Error::NotFound => e
      status 404

      syntax = plugin = ''
      sass = "// Sorry, that Gist doesn't exist.\n//#{e.to_s.gsub(/(GET|api.|https:\/\/)/, '')}"
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
        :original_syntax => syntax
      },
      :html => {
        :input => (html || ''),
        :syntax => (html_syntax || ''),
      }
    }.to_json

    erb :index
  end


  post '/gist/create' do
    inputs = params[:inputs]
    outputs = params[:outputs]

    sass = inputs[:sass][:input]

    dependencies = pack_dependencies(sass)

    css = outputs[:css]

    description = "Generated by SassMeister.com."

    sass_file = "SassMeister-input.#{inputs[:sass][:syntax].downcase}"
    css_file = "SassMeister-output.css"

    html = {}

    if inputs[:html]
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

    data = @github.gists.create(description: description, public: true, files: {
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

    dependencies = pack_dependencies(sass)

    css = outputs[:css]

    if inputs[:sass_filename].slice(-4, 4) == inputs[:sass][:syntax].downcase
      sass_file = inputs[:sass_filename]
      deleted_files = {}
    else
      sass_file = "#{inputs[:sass_filename].slice(0..-5)}#{inputs[:sass][:syntax].downcase}"
      deleted_files = {inputs[:sass_filename] => {content: nil}}
    end

    css_file = "SassMeister-output.css"

    html = {}

    if inputs[:html]
      html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      html_input = inputs[:html][:input]
      rendered_file = "SassMeister-rendered.html"
      html_output = outputs[:html]

      if inputs[:html_filename].split('.').last == inputs[:html][:syntax].downcase
        html_file = inputs[:html_filename]
        deleted_html = {}
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

    data = @github.gists.edit(id, files: {
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

    data = @github.gists.fork(id)

    content_type 'application/json'

    { id: data.id }.to_json.to_s
  end

  run! if app_file == $0
end
