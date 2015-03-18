require 'socket'
require 'json'

module Plugins
  module LoginServer
    class Server
      def initialize logger
        @server = TCPServer.open(CONFIG['login_server']['port'])
        logger.puts 'server started'
        loop do
          begin
            client = @server.accept
            request = JSON.parse(client.gets)
            logger.puts (request['password'] ? request.merge({'password' => '****'}) : request)

            user = User.new(request['key'])

            case request['command']
            when 'login'
              result = user.login(request['login'], request['password'], request['host'])
              client.puts result
            when 'logout'
              result = user.logout
              client.puts result
            when 'exec'
              if user.login?
                client.puts user.exec(request['line'])
              else
                client.puts nil
              end
            else
              logger.puts 'undifined command'
            end
            client.close
          rescue StandardError => e
            logger.puts 'ERROR ' + e.to_s
          end
        end
      end

      def destroy
        @server.close
      end
    end
  end
end
