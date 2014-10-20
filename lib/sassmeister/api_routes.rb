# require 'sassmeister/helpers'
require 'sassmeister/client'

module SassMeister
  class ApiRoutes < Sinatra::Base
    configure :development do
      COMPILER_ENDPOINTS = {
        '3.4' => 'http://sass34.sassmeister.dev',
        '3.3' => 'http://sass33.sassmeister.dev',
        '3.2' => 'http://sass32.sassmeister.dev',
        'lib' => 'http://lib.sassmeister.dev'
      }
    end

    configure :production do
      COMPILER_ENDPOINTS = {
        '3.4' => 'http://sassmeister-34.herokuapp.com',
        '3.3' => 'http://sassmeister-33.herokuapp.com',
        '3.2' => 'http://sassmeister-32.herokuapp.com',
        'lib' => 'http://libsass.api.sassmeister.com'
      }
    end

    set :protection, :except => :frame_options

    before '/app/:compiler/*' do
      return erb :'404' unless COMPILER_ENDPOINTS.include? params[:compiler]

      @api = SassMeister::Client.new(COMPILER_ENDPOINTS[params[:compiler]])
    end


    after '/app/:compiler/*' do
      headers @api.headers
    end


    get '/app/:compiler/extensions' do
      @api.extensions

      return @api.body
    end


    post '/app/:compiler/compile' do
      @api.compile params

      return @api.body
    end


    post '/app/:compiler/convert' do
      if params[:compiler] == 'lib'
        @api = SassMeister::Client.new(COMPILER_ENDPOINTS['3.3'])
      end

      @api.convert params

      return @api.body
    end
  end
end
