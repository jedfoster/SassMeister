$LOAD_PATH.unshift(File.join(File.dirname(File.realpath(__FILE__)), 'lib'))

require 'sinatra/base'
require 'sinatra/config_file'
require 'sinatra/respond_with'
require 'chairman'
require 'json'
require 'yaml'
require 'sassmeister/helpers'
require 'sassmeister/api_routes'

if ENV['RACK_ENV'] == 'development'
  require 'dotenv'
  Dotenv.load
end

class SassMeisterApp < Sinatra::Base
  register Sinatra::RespondWith
  register Sinatra::ConfigFile

  config_file '../config/config.yml'

  use Chairman::Routes
  use SassMeister::ApiRoutes

  helpers SassMeister::Helpers

  APP_DOMAIN = settings.app_domain
  SANDBOX_DOMAIN = settings.sandbox_domain
  CACHE_MAX_AGE = settings.cache_max_age
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
        use Rack::Session::Cookie, key: SassMeisterApp::COOKIE_DOMAIN,
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
        domain: SassMeisterApp::COOKIE_DOMAIN,
        path: '/'
      })

      response.set_cookie('avatar_url', {
        value: @user.avatar_url,
        expires: (Time.now + SassMeisterApp::SESSION_DURATION),
        domain: SassMeisterApp::COOKIE_DOMAIN,
        path: '/'
      })

      response.set_cookie('gh', {
        value: session[:github_token],
        expires: (Time.now + SassMeisterApp::SESSION_DURATION),
        domain: SassMeisterApp::COOKIE_DOMAIN,
        path: '/'
      })

      redirect to '/'
    end

    after '/logout' do
      ['github_id', 'avatar_url', 'gh'].each do |cookie|
        response.delete_cookie cookie, {domain: SassMeisterApp::COOKIE_DOMAIN, path: '/'}
      end

      redirect to '/'
    end
  end


  before do
    @github = Chairman.session(session[:github_token])
    @gist = nil
    @body_class = 'app'

    if !request.secure? && ENV['RACK_ENV'] == 'production'
      redirect APP_DOMAIN
    end

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


  get '/*' do
    File.read 'public/index.html'
  end

  run! if app_file == $0
end

