require 'bundler/setup'

require 'rack/contrib'
require 'rack-cache'
require 'dalli'
require 'memcachier'

require './api/lib/rack/static_cache'
require './api/app'
require './api/app_embedded'

# Gzip responses
use Rack::Deflater

if ENV['RACK_ENV'] == 'production'
  # Set Cache-Control and ETag headers
  use Rack::StaticCache, urls: ['/js', '/img', '/css', '/fonts', '/favicon.ico'], root: 'public', duration: 90

  if memcachier_servers = ENV['MEMCACHIER_SERVERS']
    cache = Dalli::Client.new memcachier_servers.split(','), {
      username: ENV['MEMCACHIER_USERNAME'],
      password: ENV['MEMCACHIER_PASSWORD']
    }
    use Rack::Cache, verbose: true, metastore: cache, entitystore: cache

  elsif memcached_server = ENV['MEMCACHED_URL']
    cache = Dalli::Client.new memcached_server

    use Rack::Cache, verbose: true, metastore: cache, entitystore: cache
  end

  run Rack::URLMap.new({
    'http://embed.sassmeister.com/' => SassMeisterEmbeddedApp,
    '/' => SassMeisterApp
  })

else
  use Rack::Static, urls: ['/js', '/img', '/css', '/fonts', '/favicon.ico'], root: 'public'

  use Rack::Cache,
    verbose: true,
    metastore:   'memcached://localhost:11211',
    entitystore: 'memcached://localhost:11211'

  run Rack::URLMap.new({
    'http://embed.sassmeister.dev/' => SassMeisterEmbeddedApp,
    'http://local-embed.sassmeister.com/' => SassMeisterEmbeddedApp,
    '/' => SassMeisterApp
  })

end
