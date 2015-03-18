require 'yaml'

$debug = ['development', 'test', nil].include?(ENV['RACK_ENV'])
$debug.freeze

CONFIG = YAML.load_file('config.yml')
CONFIG.freeze

require 'byebug' if $debug

require './app/plugins'
$plugins = Plugins::Manager.load_plugins

require './app'
unless $debug
  run SwarmCP
else
  SwarmCP.run!
end
