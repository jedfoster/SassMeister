require "bundler/setup"

require 'rack/contrib'
require './sassmeister'

# Gzip responses
use Rack::Deflater

# Set Cache-Control and ETag headers
use Rack::StaticCache, :urls => ['/javascripts', '/stylesheets', '/fonts', '/favicon.ico'], :root => "public", :duration => 0.274
use Rack::ETag

# Run the application
run SassMeisterApp