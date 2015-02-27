require 'rubygems'
require 'byebug'
require 'sinatra'
require 'json'

load 'models/user.rb'
load 'controllers/panel_controller.rb'

configure do
  enable :sessions
  set :session_secret, (0...64).map { (33 + rand(93)).chr }.join
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
  session[:user] ? redirect('/panel') : erb(:login)
end

post '/login' do
  login = User.login(params[:user], session)
  if !login
    session[:error] = "Wrong username/password"
    redirect '/'
  else
    session[:user] = params[:user][:name]
    redirect '/panel'
  end
end

get '/logout' do
  User.logout(session)
  session[:user] = nil
  redirect '/'
end

get '/panel*' do |path|
  panel_controller(path)
end
