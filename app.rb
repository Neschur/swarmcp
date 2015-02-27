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

def panel_erb page = nil
  !session[:user] ? redirect('/') : erb(:"panel/#{page || 'main'}", layout: :panel)
end

get '/panel' do
  @info = User.command(session, 'cat /etc/lsb-release')
  panel_erb
end

get '/panel/*' do |path|
  panel_erb(path)
end
