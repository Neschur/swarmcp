require 'socket'
require 'json'

def log message
  if @logger
    @logger.puts message
  else
    puts message
  end
end

server = TCPServer.open(2626)
log 'server started'
loop do
  begin
    client = server.accept
    request = JSON.parse(client.gets)
    log (request['password'] ? request.merge({'password' => '****'}) : request)

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
      log 'undifined command'
    end
    client.close
  rescue StandardError => e
    log 'ERROR ' + e.to_s
  end
end
