ENV['RACK_ENV'] = 'test'

# Pull in all of the gems including those in the `test` group
require 'bundler'
Bundler.require :default, :test

require 'minitest/autorun'
require 'minitest/spec'
require 'rack/test'

require_relative '../sassmeister.rb'
