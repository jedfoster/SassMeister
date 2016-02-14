require 'sinatra/base'
require 'sinatra/config_file'
require 'chairman'
require 'sassmeister/client'

module SassMeister
  class ApiRoutes < Sinatra::Base
    register Sinatra::ConfigFile

    config_file '../../../config/api.yml'

    env_endpoints = {
      'lib' => ENV['LIBSASS_ENDPOINT'],
      '3.4' => ENV['SASS_34_ENDPOINT'],
      '3.3' => ENV['SASS_33_ENDPOINT'],
      '3.2' => ENV['SASS_32_ENDPOINT']
    }

    COMPILER_ENDPOINTS = settings.api[:endpoints].merge(env_endpoints) {|k, yml, env| env.nil? ? yml : env}

    set :protection, except: :frame_options

    before '/app/:compiler/*' do
      pass if params[:compiler] == 'gists'

      return status 404 unless COMPILER_ENDPOINTS.include? params[:compiler]

      @api = SassMeister::Client.new COMPILER_ENDPOINTS[params[:compiler]]
    end


    after '/app/:compiler/*' do
      headers @api.headers if @api
    end


    get '/app/gists/:id' do |id|
      Chairman.config ENV['GITHUB_ID'], ENV['GITHUB_SECRET'], ['gist']

      @github = Chairman.session(session[:github_token])

      begin
        response = @github.gist id

        raise Octokit::NotFound unless response.message.nil?

        headers({
            'content-type' => @github.last_response.headers['content-type'],
            'x-ratelimit-limit' => @github.last_response.headers['x-ratelimit-limit'],
            'x-ratelimit-remaining' => @github.last_response.headers['x-ratelimit-remaining'],
            'x-ratelimit-reset' => @github.last_response.headers['x-ratelimit-reset'],
            'last-modified' => @github.last_response.headers['last-modified'],
            'x-github-media-type' => @github.last_response.headers['x-github-media-type']
          })

      rescue Octokit::NotFound => e
        @id = id
        status 404

        return
      end

      response = response.to_attrs

      response.delete(:history)
      response.to_json
    end


    get '/app/:compiler/extensions' do
      @api.extensions

      {extensions: JSON.parse(@api.body)}.to_json
    end


    post '/app/:compiler/compile' do
      payload = request.content_type.include?('application/json') ? JSON.parse(request.body.read) : params

      @api.compile payload

      @api.body
    end


    post '/app/:compiler/convert' do
      @api = SassMeister::Client.new(COMPILER_ENDPOINTS['3.3']) if params[:compiler] == 'lib'

      payload = request.content_type.include?('application/json') ? JSON.parse(request.body.read) : params

      @api.convert payload

      @api.body
    end


    get '/app/compilers' do
      content_type 'application/json'

      cache_control :public, max_age: 2592000 # 30 days, in seconds

      compilers = SassMeister::Redis.new 'compilers'

      {compilers: Hash[compilers.value.sort_by{|k, v| k}.reverse]}.to_json
    end


    get '/app/extensions' do
      content_type 'application/json'

      cache_control :public, max_age: 2592000 # 30 days, in seconds

      extensions = SassMeister::Redis.new 'extensions'

      {extensions: Hash[extensions.value.sort]}.to_json
    end
  end
end

