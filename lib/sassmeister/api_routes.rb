require 'sassmeister/client'

module SassMeister
  class ApiRoutes < Sinatra::Base
    configure :development, :test do
      COMPILER_ENDPOINTS = {
        'lib' => 'http://lib.sassmeister.dev',
        '3.4' => 'http://sass34.sassmeister.dev',
        '3.3' => 'http://sass33.sassmeister.dev',
        '3.2' => 'http://sass32.sassmeister.dev'
      }
    end

    configure :production do
      COMPILER_ENDPOINTS = {
        'lib' => ENV['LIBSASS_ENDPOINT'] || 'http://libsass.api.sassmeister.com',
        '3.4' => ENV['SASS_34_ENDPOINT'] || 'http://sassmeister-34.herokuapp.com',
        '3.3' => ENV['SASS_33_ENDPOINT'] || 'http://sassmeister-33.herokuapp.com',
        '3.2' => ENV['SASS_32_ENDPOINT'] || 'http://sassmeister-32.herokuapp.com'
      }
    end

    set :protection, except: :frame_options

    before '/app/:compiler/*' do
      return erb :'404' unless COMPILER_ENDPOINTS.include? params[:compiler]

      @api = SassMeister::Client.new COMPILER_ENDPOINTS[params[:compiler]]
    end


    after '/app/:compiler/*' do
      headers @api.headers
    end


    get '/app/compilers' do
      x = []
      COMPILER_ENDPOINTS.each do |compiler|
        api = SassMeister::Client.new compiler[1]

        x.push JSON.parse(api.body) if api.root == 200
      end

      content_type 'application/json'

      JSON.generate x
    end


    get '/app/:compiler/extensions' do
      @api.extensions

      @api.body
    end


    post '/app/:compiler/compile' do
      @api.compile params

      @api.body
    end


    post '/app/:compiler/convert' do
      @api = SassMeister::Client.new(COMPILER_ENDPOINTS['3.3']) if params[:compiler] == 'lib'

      @api.convert params

      @api.body
    end
  end
end

