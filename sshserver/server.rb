require 'socket'
require 'json'
load 'user.rb'

server = TCPServer.open(2626)
puts 'server started'
loop do
  begin
    client = server.accept
    request = JSON.parse(client.gets)
    puts (request['password'] ? request.merge({'password' => '****'}) : request)

    case request['command']
    when 'login'
      result = User.login(request['login'], request['password'], request['key'], request['host'])
      client.puts result
    when 'logout'
      result = User.logout(request['key'])
      client.puts result
    when 'exec'
      if User.login?(request['key'])
        client.puts User.exec(request['key'], request['line'])
      else
        client.puts nil
      end
    else
      puts 'undifined command'
    end
    client.close
  rescue StandardError => e
    puts 'ERROR ' + e.to_s
  end
end
