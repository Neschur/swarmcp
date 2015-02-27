require 'rubygems'
require 'byebug'
require 'sinatra'
require 'json'

load 'models/user.rb'
load 'controllers/panel_controller.rb'
load 'controllers/terminal_controller.rb'

configure do
  enable :sessions
  set :session_secret, (0...64).map { (33 + rand(93)).chr }.join if !ENV['DEBUG']
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
  login = SSH.login(params[:user], session)
  if !login
    session[:error] = "Wrong username/password"
    redirect '/'
  else
    session[:user] = params[:user][:name]
    redirect '/panel'
  end
end

get '/logout' do
  SSH.logout(session)
  session[:user] = nil
  redirect '/'
end

get '/panel/terminal/ajax=*' do |path|
  terminal_controller(path)
end

get '/panel*' do |path|
  panel_controller(path)
end
