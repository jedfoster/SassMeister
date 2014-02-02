require "bundler/setup"

require 'rack/contrib'
require './lib/rack/static_cache'

require './sassmeister'

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

# Run the application
run SassMeisterApp
