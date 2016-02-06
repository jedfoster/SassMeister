source 'http://rubygems.org'
ruby '2.2.3'

gem 'rack-contrib'
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
  gem 'execjs'
  gem 'rake'
  gem 'sass'
  gem 'compass', "1.0.0.alpha.18"
  gem 'ffi', "= 1.9.0"
  gem 'stipe'
  gem 'jammit'
  gem 'closure-compiler'
end

group :development, :test do
  gem 'pry-remote'
  gem 's3_website', :github => 'jedfoster/s3_website', :branch => '1.x'
  gem 'rack-test'
  gem 'rack-env'
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
