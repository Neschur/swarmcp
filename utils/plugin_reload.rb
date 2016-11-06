require 'yaml'
require 'byebug'

port = YAML.load_file('config.yml')['plugins_reloader']['port']
socket = TCPSocket.new('localhost', port)
socket.puts ARGV[0]
socket.gets
socket.close
