require_relative 'app.rb'

class SassMeisterEmbeddedApp < SassMeisterApp
  set :protection, except: :frame_options

  get '/' do
    redirect "http://#{APP_DOMAIN}"
  end

  get '/*' do
    File.read 'public/embed.html'
  end

  run! if app_file == $0
end

