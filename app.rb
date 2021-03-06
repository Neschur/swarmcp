require 'rubygems'
require 'sinatra/base'
require 'json'

require './app/ssh_session'

class SwarmCP < Sinatra::Application
  configure do
    enable :sessions
    set :session_secret, (0...64).map { (33 + rand(93)).chr }.join unless $debug
  end

  helpers do
    def flash
      return if !session[:error]
      message = session[:error]
      session[:error] = nil
      "<div class='alert alert-danger'>#{message}</div>"
    end
  end

  before do
    unless defined?(@@_panel_plugins)
      @@_panel_plugins = $plugins.select{|id, plugin| plugin['panel']}
    end

    @panel_plugins = @@_panel_plugins

    @ssh_session ||= SSHSession.new(session, CONFIG['login_server']['port'])
  end

  get '/' do
    session[:user] ? redirect('/panel') : erb(:'./login')
  end

  post '/login' do
    login = @ssh_session.login(params[:user])
    if !login
      session[:error] = "Wrong username/password"
      redirect '/'
    else
      session[:user] = params[:user][:name]
      redirect '/panel'
    end
  end

  get '/logout' do
    @ssh_session.logout
    session[:user] = nil
    redirect '/'
  end

  before '/panel*' do
    redirect('/') if !session[:user]
  end

  # Dashboard
  get /\/panel.{0,1}$/ do
    @info = @ssh_session.exec('cat /etc/lsb-release')
    erb(:dashboard, layout: :panel)
  end

  get '/panel/*' do |path|
    def render_erb name
      erb File.read("plugins/#{@plugin_id}/#{name}.erb"), layout: :panel
    end

    @plugin_id = path.split('/')[0]
    @plugin_js_list = Dir["plugins/#{@plugin_id}/public/*.js"].map{|js|js.sub('/public','')}

    path.sub!("#{@plugin_id}", ''); path[0] = '' if path[0] == '/'
    load "plugins/#{@plugin_id}/#{@panel_plugins[@plugin_id]['panel']}"
    send("#{@plugin_id}_controller", path)
  end

  get '/plugins/*/*.js' do |plugin, filename|
    content_type :js
    File.read("plugins/#{plugin}/public/#{filename}.js")
  end
end
