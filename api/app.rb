$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'sinatra/base'
require 'sinatra/partial'
require 'sinatra/config_file'
require 'sinatra/respond_with'
require 'chairman'
require 'json'
require 'yaml'
require 'sassmeister/helpers'
require 'object'
require 'array'
require 'assets'
require 'sassmeister/api_routes'

if ENV['RACK_ENV']
  require 'dotenv'
  Dotenv.load
end

class SassMeisterApp < Sinatra::Base
  register Sinatra::RespondWith
  register Sinatra::Partial
  register Sinatra::ConfigFile

  set :partial_template_engine, :erb

  config_file '../config/config.yml'

  use Chairman::Routes
  use SassMeister::ApiRoutes

  helpers SassMeister::Helpers
  helpers Assets

  APP_DOMAIN = settings.app_domain
  SANDBOX_DOMAIN = settings.sandbox_domain
  CACHE_MAX_AGE = settings.cache_max_age
  Assets::HOST = settings.assets_host unless defined? Assets::HOST
  COOKIE_DOMAIN = settings.cookie_domain
  COOKIE_SECRET = ENV['COOKIE_SECRET'] || settings.cookie_secret
  APP_VERSION = settings.app_version
  SESSION_DURATION = settings.session_duration
  Chairman.config ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist']

  configure :production do
    require 'newrelic_rpm'
  end

  # implement redirects
  class Chairman::Routes
    configure do
      helpers do
        use Rack::Session::Cookie, key: SassMeisterApp::APP_DOMAIN,
                                   domain: SassMeisterApp::COOKIE_DOMAIN,
                                   path: '/',
                                   expire_after: SassMeisterApp::SESSION_DURATION,
                                   secret: SassMeisterApp::COOKIE_SECRET
       end
    end

    after '/authorize/return' do
      session[:version] == SassMeisterApp::APP_VERSION
      
      response.set_cookie('github_id', {
        value: @user.login,
        expires: (Time.now + SassMeisterApp::SESSION_DURATION),
        # domain: SassMeisterApp::COOKIE_DOMAIN,
        path: '/'
      })

      response.set_cookie('avatar_url', {
        value: @user.avatar_url,
        expires: (Time.now + SassMeisterApp::SESSION_DURATION),
        # domain: SassMeisterApp::COOKIE_DOMAIN,
        path: '/'
      })

      response.set_cookie('gh', {
        value: session[:github_token],
        expires: (Time.now + SassMeisterApp::SESSION_DURATION),
        # domain: SassMeisterApp::COOKIE_DOMAIN,
        path: '/'
      })

      redirect to '/'
    end

    after '/logout' do
      ['github_id', 'avatar_url'].each do |cookie|
        response.delete_cookie cookie, {domain: SassMeisterApp::COOKIE_DOMAIN, path: '/'}
      end

      redirect to '/'
    end
  end


  before do
    @github = Chairman.session(session[:github_token])
    @gist = nil
    @body_class = 'app'

    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?

    headers 'Access-Control-Allow-Origin' => origin if origin

    if request.get?
      cache_control :public, max_age: CACHE_MAX_AGE

      last_modified app_last_modified.httpdate unless request.path.include? 'gist'
    end
  end

  before /^(?!\/(authorize))/ do
    if session[:version].nil? || session[:version] != APP_VERSION
      session[:github_token] = nil
      session[:github_id] = nil
      @force_invalidate = true
      session[:version] = APP_VERSION

      # Delete the user info cookies, too
      ['github_id', 'avatar_url'].each do |cookie|
        response.delete_cookie cookie, {domain: SassMeisterApp::COOKIE_DOMAIN, path: '/'}
      end
    end
  end


  get %r{/api/gist(?:/[\w-]*)*/([\d\w]+)} do
    id = params[:captures].first

    begin
      response = @github.gist(id)

      raise Octokit::NotFound unless response.message.nil?

      last_modified response.updated_at.httpdate

      # For now, we only return the first .sass or .scss file we find.
      file = response.files["#{response.files._fields.grep(/.+\.(scss|sass)/i)[0]}"]

      if( ! file)
        syntax = filename = owner = ''
        sass = "// Sorry, I couldn't find any valid Sass in that Gist."

      else
        sass = file.content
        filename = file.filename
        owner = ((response.respond_to?(:user) && response.user) ? response.user.login : nil)

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

    @gist = {
      gist_id: id,
      owner: owner,
      sass_filename: filename,
      html_filename: (html_filename || ''),
      sass: {
        input: sass,
        syntax: syntax,
        original_syntax: syntax,
        dependencies: get_frontmatter_dependencies(sass)
      },
      html: {
        input: (html || '').gsub('</script>', '<\/script>'),
        syntax: (html_syntax || '').gsub('</script>', '<\/script>')
      }
    }

    @gist_output = {
      css: (css_file || ''),
      html: (rendered_file || '').gsub('</script>', '<\/script>')
    }

    respond_to do |wants|
      wants.html { erb :index }
      wants.json { response.data.to_json }
    end
  end


  post '/api/gist/create' do
    inputs = params[:inputs]
    outputs = params[:outputs]

    sass = inputs[:sass][:input]

    dependencies = pack_dependencies(sass, inputs[:sass][:dependencies])

    sass = "#{dependencies}\n\n#{sass}"

    css = outputs[:css]

    description = 'Generated by SassMeister.com.'

    sass_file = "SassMeister-input.#{inputs[:sass][:syntax].downcase}"
    css_file = 'SassMeister-output.css'

    html = {}

    if inputs[:html] && inputs[:html][:input].chomp != ''
      html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      html_input = inputs[:html][:input]
      rendered_file = 'SassMeister-rendered.html'
      html_output = outputs[:html]

      html = {
        html_file => {
          content: html_input
        },
        rendered_file => {
          content: html_output
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


  post %r{/api/gist(?:/[\w-]*)*/([\d\w]+)/edit} do
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

    css_file = 'SassMeister-output.css'

    html = {}

    if inputs[:html] && inputs[:html][:input].chomp != ''
      html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      html_input = inputs[:html][:input]
      rendered_file = 'SassMeister-rendered.html'
      html_output = outputs[:html]

      deleted_html = {}

      if inputs[:html_filename] == ''
        html_file = "SassMeister-input-HTML.#{inputs[:html][:syntax].downcase}"
      elsif inputs[:html_filename].split('.').last == inputs[:html][:syntax].downcase
        html_file = inputs[:html_filename]
      else
        filename = inputs[:html_filename].split '.'
        filename.pop
        filename = filename.join '.'

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
      }.merge deleted_html
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

  post %r{/api/gist(?:/[\w-]*)*/([\d\w]+)/fork} do
    id = params[:captures].shift

    data = @github.fork_gist(id)

    content_type 'application/json'

    { id: data.id }.to_json.to_s
  end

  get '/' do
    File.read 'public/index.html'
  end

  get %r{/gist(?:/[\w-]*)*/([\d\w]+)} do
    File.read 'public/index.html'
  end

  get %r{about|thankyou} do
    File.read 'public/index.html'
  end


  run! if app_file == $0
end

