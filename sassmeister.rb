$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'sinatra/base'
require 'sinatra/partial'
require 'chairman'
require 'json'
require 'yaml'
require 'sassmeister'
require 'object'
require 'array'
require 'assets'

class SassMeisterApp < Sinatra::Base
  register Sinatra::Partial

  use Chairman::Routes

  helpers SassMeister
  helpers Assets

  configure do
    APP_VERSION = '2.0.1'
    SESSION_DURATION = 7776000 # 90 days, in seconds
  end

  # implement redirects
  class Chairman::Routes
    configure :production do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.com',
                                   :domain => '.sassmeister.com',
                                   :path => '/',
                                   :expire_after => SassMeisterApp::SESSION_DURATION,
                                   :secret => ENV['COOKIE_SECRET']
       end
    end

    configure :development do
      helpers do
        use Rack::Session::Cookie, :key => 'sassmeister.dev',
                                   :path => '/',
                                   :expire_after => SassMeisterApp::SESSION_DURATION, # 90 days, in seconds
                                   :secret => 'local'
      end
    end

    after '/authorize/return' do
      session[:version] == SassMeisterApp::APP_VERSION

      ['github_id', 'gravatar_id'].each do |cookie|
        response.set_cookie(cookie, {
          :value => session[cookie.to_sym], 
          :max_age => "#{SassMeisterApp::SESSION_DURATION}",
          :expires => (Time.now + SassMeisterApp::SESSION_DURATION),
          :domain => '.sassmeister.com',
          :path => '/'
        })
      end

      redirect to('/')
    end

    after '/logout' do
      ['github_id', 'gravatar_id'].each do |cookie|
        response.delete_cookie cookie, {:domain => '.sassmeister.com', :path => '/'}
      end

      redirect to('/')
    end
  end

  set :partial_template_engine, :erb

  configure :production do
    APP_DOMAIN = 'sassmeister.com'
    SANDBOX_DOMAIN = 'sandbox.sassmeister.com'
    Assets::HOST = 'http://cdn.sassmeister.com'
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

      return uri.match(/^http:\/\/(.+\.){0,1}sassmeister\.(com|dev|((\d+\.){4}xip\.io))/)
    end
  end


  before do
    @github = Chairman.session(session[:github_token])
    @gist = nil

    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?

    headers 'Access-Control-Allow-Origin' => origin if origin

    if request.request_method == "GET"
      cache_control :public, max_age: 1800  # 30 mins.

      headers 'Last-Modified' => app_last_modified.httpdate unless request.path.include? 'gist'
    end
  end

  before /^(?!\/(authorize))/ do
    if session[:version].nil? || session[:version] != APP_VERSION
      session[:github_token] = nil
      session[:github_id] = nil
      @force_invalidate = true
      session[:version] = APP_VERSION
    end
  end


  not_found do
    @body_class = 'oops-404'

    return erb :'404' unless @id

    return erb :'gist-404', locals: {id: @id}
  end


  get '/' do
    @body_class = false

    erb :index
  end


  get '/thankyou' do
    @body_class = 'thankyou'

    erb :thankyou
  end


  get '/about' do
    @body_class = 'about'

    erb :about
  end


  get %r{/gist(?:/[\w]*)*/([\d\w]+)} do
    id = params[:captures].first

    begin
      response = @github.gist(id)

      raise Octokit::NotFound unless response.message.nil?

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

      if css_file = response.files["#{response.files._fields.grep(/.+-output\.css/)[0]}"]
        css_file = css_file.content.to_s
      end

      if rendered_file = response.files["#{response.files._fields.grep(/.+-rendered\.html/)[0]}"]
        rendered_file = response.files["#{response.files._fields.grep(/.+-rendered\.html/)[0]}"].content.to_s
      end

    rescue Octokit::NotFound => e
      @id = id
      status 404

      return
    end

    headers 'Last-Modified' => response.updated_at.httpdate

    @gist = {
      :gist_id => id,
      :gist_owner => owner,
      :sass_filename => filename,
      :html_filename => (html_filename || ''),
      :sass => {
        :input => sass,
        :syntax => syntax,
        :original_syntax => syntax,
        :dependencies => get_frontmatter_dependencies(sass)
      },
      :html => {
        :input => (html || '').gsub('</script>', '<\/script>'),
        :syntax => (html_syntax || '').gsub('</script>', '<\/script>')
      }
    }

    @gist_output = {
      :css => (css_file || ''),
      :html => (rendered_file || '').gsub('</script>', '<\/script>')
    }

    @body_class = false

    erb :index
  end


  post '/gist/create' do
    inputs = params[:inputs]
    outputs = params[:outputs]

    sass = inputs[:sass][:input]

    dependencies = pack_dependencies(sass, inputs[:sass][:dependencies])

    sass = "#{dependencies}\n\n#{sass}"

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

    files = {}

    files.merge!({ css_file => { content: "#{css}" } }) if css.chomp != ''

    files.merge!({ sass_file => { content: "#{sass}" } }) if sass.chomp != ''

    files.merge!(html)

    unless files == {}
      data = @github.create_gist(description: description, public: true, files: files)
    end

    content_type 'application/json'

    {
      id: data.id,
      sass_filename: sass_file,
      html_filename: html_file
    }.to_json.to_s if data
  end


  post %r{/gist(?:/[\w]*)*/([\d\w]+)/edit} do
    id = params[:captures].shift

    inputs = params[:inputs]
    outputs = params[:outputs]

    sass = inputs[:sass][:input]

    dependencies = pack_dependencies(sass, inputs[:sass][:dependencies])

    sass = "#{dependencies}\n\n#{sass}"

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

    files = {}

    files.merge!({ css_file => { content: "#{css}" } }) if css.chomp != ''

    files.merge!({ sass_file => { content: "#{sass}" } }) if sass.chomp != ''

    files.merge!(deleted_files).merge!(html)

    unless files == {}
      data = @github.edit_gist(id, files: files)
    end

    content_type 'application/json'

    {
      id: data.id,
      sass_filename: sass_file,
      html_filename: html_file
    }.to_json.to_s if data
  end

  post %r{/gist(?:/[\w]*)*/([\d\w]+)/fork} do
    id = params[:captures].shift

    data = @github.fork_gist(id)

    content_type 'application/json'

    { id: data.id }.to_json.to_s
  end

  run! if app_file == $0
end
