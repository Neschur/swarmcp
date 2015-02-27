require 'rubygems'
require 'sinatra'

configure do
  enable :sessions
end

get '/' do
  erb :login
end
