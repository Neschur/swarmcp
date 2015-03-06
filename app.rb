require 'rubygems'
require 'byebug' if ENV['DEBUG']
require 'sinatra'
require 'json'
require 'yaml'

require './ssh'

class SwarmCP < Sinatra::Application
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

    def plugins
      return @@plugins if defined?(@@plugins)
      @@plugins = {}
      Dir['plugins/*'].map do |plugin_dir|
        puts "load plugin: #{plugin_dir}"
        @@plugins[plugin_dir.sub('plugins/','')] = YAML.load_file("#{plugin_dir}/info.yml")
      end
      @@plugins
    end

    def panel_plugins
      plugins.select{|id, plugin| plugin['panel']}
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

    if path.size < 1
      @info = SSH.command(session, 'cat /etc/lsb-release')
      erb(:dashboard, layout: :panel)
    else
      def render_erb name
        erb File.read("plugins/#{@plugin_id}/#{name}.erb"), layout: :panel
      end

      @plugin_id = path.split('/')[0]
      path.sub!("#{@plugin_id}", ''); path[0] = '' if path[0] == '/'
      @plugin_js_list = Dir["plugins/#{@plugin_id}/public/*.js"].map{|js|js.sub('/public','')}
      load "plugins/#{@plugin_id}/#{plugins[@plugin_id]['panel']}"
      send("#{@plugin_id}_controller", path)
    end
  end

  get '/plugins/*/*.js' do |plugin, filename|
    content_type :js
    File.read("plugins/#{plugin}/public/#{filename}.js")
  end
end
