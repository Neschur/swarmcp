require 'rubygems'
require 'byebug'
require 'sinatra'
require 'json'

class User
  def self.login user, session
    socket = get_socket
    socket.puts({
        command: 'login',
        login: user[:name],
        password: user[:password],
        key: key(session),
        host: 'localhost'
      }.to_json)
    response = socket.gets
    socket.close
    response.strip == 'true'
  end

  private
  def self.get_socket
    TCPSocket.new('localhost', 2626)
  end

  def self.key session
    session[:session_id]
  end
end

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
