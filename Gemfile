source 'http://rubygems.org'
ruby '2.0.0'

gem 'rack-contrib', :git => 'git://github.com/rack/rack-contrib.git'
gem 'sinatra'
gem 'sinatra-partial'
gem 'unicorn'
gem 'chairman'
gem 'rack-cache'
gem 'activesupport'

group :assets do
  gem 'execjs'
  gem 'rake'
  gem 'sass', "~> 3.3.0.rc.2"
  gem 'compass', "~> 1.0.0.alpha.17"
  gem 'stipe'
  gem 'jammit'
  gem 'closure-compiler'
end

group :development do
  gem 'pry-remote'
  gem 's3_website'
end

group :production do
  gem 'newrelic_rpm'
end
