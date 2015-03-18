require 'net/ssh'

module Plugins
  module LoginServer
    class User
      EXPIRE_TIME = 3600
      @@shells = {}

      def initialize key
        @key = key
      end

      def login name, password, host
        shell = get_shell(name, password, host)
        @@shells[@key] = {
          shell: shell,
          time: Time.now,
        }
        !!shell
      end

      def login?
        !!shell
      end

      def exec command
        shell.exec!(command)
      end

      def logout
        @@shells[@key] = nil
      end

      private
      def shell
        shell = @@shells[@key]
        return if !shell
        if (Time.now - shell[:time] > EXPIRE_TIME)
          @@shells[session[:session_id] + session[:_csrf_token]] = nil
        else
          shell[:shell]
        end
      end

      def get_shell name, password, host
        shell = nil
        start_time = Time.new
        login = Thread.new do
          shell = Net::SSH.start(host, name, :password => password)
        end
        while(!(Time.now - start_time > 5 || shell))
          sleep(0.1)
        end
        login.kill
        shell
      end
    end
  end
end