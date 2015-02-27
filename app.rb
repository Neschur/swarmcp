require 'rubygems'
require 'byebug'
require 'sinatra'
require 'json'

load 'models/user.rb'

configure do
  enable :sessions
end

helpers do
  def flash
    return if !session[:error]
    message = session[:error]
    session[:error] = nil
    "<div class='alert alert-danger'>#{message}</div>"
  end
end

get '/' do
  session[:user] ? erb(:panel) : erb(:login)
end

post '/login' do
  login = User.login(params[:user], session)
  if !login
    session[:error] = "Wrong username/password"
  else
    session[:user] = params[:user][:name]
  end
  redirect '/'
end
