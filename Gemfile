source 'http://rubygems.org'
ruby '2.0.0'

gem 'rack-contrib', :git => 'git://github.com/rack/rack-contrib.git'
gem 'sinatra'
gem 'sinatra-partial'
gem 'unicorn'
gem 'chairman'
gem 'rack-cache'
gem 'activesupport'
gem 'faraday'

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

group :development do
  gem 'pry-remote'
  gem 's3_website', :github => 'jedfoster/s3_website', :branch => '1.x'
end

group :production do
  gem 'newrelic_rpm'
end
