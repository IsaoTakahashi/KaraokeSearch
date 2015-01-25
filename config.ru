root = ::File.dirname(__FILE__)
require ::File.join(root, 'app')
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'].to_sym)
require 'sinatra/twitter-bootstrap'

run Server
