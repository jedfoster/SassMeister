require "bundler/setup"

require 'rack/contrib'
require './lib/rack/static_cache'

# Gzip responses
use Rack::Deflater

if ENV['RACK_ENV'] != 'production'
  map "/js" do
    run Rack::File.new("javascripts")
  end
else

# Set Cache-Control and ETag headers
use Rack::StaticCache, :urls => ['/js', '/css', '/fonts', '/favicon.ico'], :root => "public", :duration => 90
end

require './sassmeister'
require './sassmeister_embedded'

if ENV['RACK_ENV'] != 'production'
  run Rack::URLMap.new({
    "http://embed.sassmeister.dev/" => SassMeisterEmbeddedApp,
    "/" => SassMeisterApp
  })
else
  run Rack::URLMap.new({
    "http://embed.sassmeister.com/" => SassMeisterEmbeddedApp,
    "/" => SassMeisterApp
  })
end
