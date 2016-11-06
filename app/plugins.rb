require 'yaml'
require 'digest'
require 'active_support/core_ext/string'

module Plugins
  class Logger
    def initialize file_name
      @file_name = 'log/' + file_name + '.log'
    end

    def puts message
      File.open(@file_name, 'a') do |f|
        f.write(Time.now.to_s + ' ' + message.to_s + "\n")
      end
    end
  end

  module Manager
    def self.load_plugins
      plugins = read
      require_plugins plugins

      Thread.new do
        server = TCPServer.open(CONFIG['plugins_reloader']['port'])

        loop do
          client = server.accept
          plugin_id = client.gets.strip
          plugin = plugins[plugin_id]
          client.close
          next if !plugin

          reload_plugins plugins
        end
      end

      plugins
    end

    private
    def self.read
      plugins = {}
      Dir['plugins/*'].map do |dir|
        puts "load plugin: #{dir}"
        info = YAML.load_file("#{dir}/info.yml")
        plugins[dir.gsub('plugins/', '')] = info.merge({'dir' => dir}).merge({'md5' => md5(dir)})
      end
      plugins
    end

    def self.md5 plugin
      data = ""
      Dir['plugins/terminal/**/*'].select { |f| File.file?(f) }.each do |file|
        data << File.read(file)
      end
      Digest::MD5.digest(data)
    end

    def self.require_plugins plugins
      plugins.select{|*, info| info['require']}.each do |id, info|
        Thread.new do
          begin
            logger = Logger.new id
            info['require'].split(', ').each do |file|
              require './' + info['dir'] + '/' + file
            end
            (info['create'] || '').split(', ').each do |file|
              klass = (info['dir'].classify + '::' + info['create']).constantize
              info['objects'] ||= []
              info['objects'] << klass.new(logger)
            end
          rescue Exception => e
            puts "exception in plugin #{id}: #{e.to_s}"
          end
        end
      end
    end

    def reload_plugins plugins
      newp = read
      newp.each
    end

    # def self.reload_plugin plugin
    #   dir = "plugins/#{plugin}"
    #   info = YAML.load_file("plugins/#{dir}/info.yml")
    #   plugins[plugin] = info.merge({'dir' => dir})

    #   puts 'reload plugin: ' + plugin
    #   info['require'].split(', ').each do |file|
    #     require './' + info['dir'] + '/' + file
    #   end
    #   (info['create'] || '').split(', ').each do |file|
    #     klass = (info['dir'].classify + '::' + info['create']).constantize
    #     info['objects'] ||= []
    #     info['objects'] << klass.new(logger)
    #   end
    #   debugger
    #   plugin_class = (plugin['dir'].classify + '::' + plugin['create']).constantize
    # end
  end
end
