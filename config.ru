require "bundler/setup"

require 'rack/contrib'
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


if memcache_host = ENV['MEMCACHIER_SERVERS'] || 'localhost:11211'
  use Rack::Cache,
    verbose: true,
    metastore:   "memcached://#{memcache_host}",
    entitystore: "memcached://#{memcache_host}"
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