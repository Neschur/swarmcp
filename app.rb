require 'rubygems'
require 'byebug'
require 'sinatra'
require 'json'

load 'ssh.rb'

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

get '/panel*' do |path|
  redirect('/') if !session[:user]
  path[0] = '' if path[0] == '/'

  @plugins = Dir['plugins/*'].map{|p| p.sub('plugins/','')}

  if path.size < 1
    @info = SSH.command(session, 'cat /etc/lsb-release')
    erb(:panel_main, layout: :panel)
  else
    def render_erb name
      erb File.read("plugins/#{@plugin}/#{name}.erb"), layout: :panel
    end

    @plugin = path.split('/')[0]
    path.sub!("#{@plugin}", ''); path[0] = '' if path[0] == '/'
    @plugin_js_list = Dir["plugins/#{@plugin}/public/*.js"].map{|js|js.sub('/public','')}
    load "plugins/#{@plugin}/controller.rb"
    send("#{@plugin}_controller", path)
  end
end

get '/plugins/*/*.js' do |plugin, filename|
  content_type :js
  File.read("plugins/#{plugin}/public/#{filename}.js")
end
