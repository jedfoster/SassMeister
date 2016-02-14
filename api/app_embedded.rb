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

class SassMeisterEmbeddedApp < Sinatra::Base
  register Sinatra::RespondWith
  register Sinatra::Partial
  register Sinatra::ConfigFile

  set :partial_template_engine, :erb
  set :protection, except: :frame_options

  config_file '../config/config.yml'

  use SassMeister::ApiRoutes

  helpers SassMeister::Helpers
  helpers Assets

  APP_DOMAIN = settings.app_domain
  SANDBOX_DOMAIN = settings.sandbox_domain
  CACHE_MAX_AGE = settings.cache_max_age
  # Assets::HOST = settings.assets_host
  Assets::HOST = settings.assets_host unless defined? Assets::HOST

  COOKIE_DOMAIN = settings.cookie_domain
  APP_VERSION = settings.app_version
  SESSION_DURATION = settings.session_duration
  Chairman.config ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist']

  before do
    @github = Chairman.session(nil)
    @gist = nil

    params[:syntax].downcase! unless params[:syntax].nil?
    params[:original_syntax].downcase! unless params[:original_syntax].nil?

    cache_control :public, max_age: CACHE_MAX_AGE
  end


  get '/' do
    redirect "http://#{APP_DOMAIN}"
  end


  get %r{/gists(?:/[\w]*)*/([\d\w]+)} do
    id = params[:captures].first

    begin
      response = @github.gist id

      raise Octokit::NotFound unless response.message.nil?

      last_modified response.updated_at.httpdate

    rescue Octokit::NotFound => e
      @id = id
      status 404

      return
    end

    response = response.to_attrs

    response.delete(:history)
    response.to_json
  end

  get '/*' do
    File.read 'public/embed.html'
  end

  run! if app_file == $0
end

