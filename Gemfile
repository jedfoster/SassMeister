source 'http://rubygems.org'
ruby '2.0.0'

gem 'rack-contrib', :git => 'git://github.com/rack/rack-contrib.git'
gem 'sinatra'
gem 'sinatra-partial'
gem 'sinatra-contrib'
gem 'unicorn'
gem 'chairman'
gem 'rack-cache'
gem 'activesupport'
gem 'faraday'
gem 'sawyer'
gem 'thor'

group :assets do
  gem 'rake'
end

group :development, :test do
  gem 'pry-remote'
  gem 's3_website', :github => 'jedfoster/s3_website', :branch => '1.x'
  gem 'rack-test'
  gem 'dotenv'
  gem 'nokogiri'
end

group :test do
  gem 'fakeredis'
end

group :develeopment, :production do
  gem 'redis'
end

group :production do
  gem 'newrelic_rpm'
end
