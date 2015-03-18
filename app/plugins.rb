require 'yaml'
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

  class Manager
    def self.load_plugins
      plugins = {}
      Dir['plugins/*'].map do |plugin_dir|
        puts "load plugin: #{plugin_dir}"
        plugin_info = YAML.load_file("#{plugin_dir}/info.yml")
        plugins[plugin_dir.gsub('plugins/', '')] = plugin_info.merge({'dir' => plugin_dir})
      end
      plugins.freeze

      plugins.select{|*, info| info['require']}.each do |id, info|
        Thread.new do
          begin
            logger = Logger.new id
            info['require'].split(', ').each do |file|
              require './' + info['dir'] + '/' + file
            end
            info['create'].split(', ').each do |file|
              klass = (info['dir'].classify + '::' + info['create']).constantize
              klass.new logger
            end
          rescue Exception => e
            puts "exception in pluggin #{id}: #{e.to_s}"
          end
        end
      end
      plugins
    end
  end
end
