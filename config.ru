require "bundler/setup"

require 'rack/contrib'
require 'dalli'
require 'memcachier'
require './lib/rack/static_cache'

require './sassmeister'
require './sassmeister_embedded'


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


if memcachier_servers = ENV['MEMCACHIER_SERVERS']
  cache = Dalli::Client.new memcachier_servers.split(','), {
    username: ENV['MEMCACHIER_USERNAME'],
    password: ENV['MEMCACHIER_PASSWORD']
  }
  use Rack::Cache, verbose: true, metastore: cache, entitystore: cache
end


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
