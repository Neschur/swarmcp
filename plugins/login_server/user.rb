require 'net/ssh'

class User
  EXPIRE_TIME = 3600
  @@shells = {}

  def self.login name, password, key, host
    shell = get_shell(name, password, host)
    @@shells[key] = {
      shell: shell,
      time: Time.now,
    }
    !!shell
  end

  def self.login? key
    !!shell(key)
  end

  def self.exec key, command
    shell(key).exec!(command)
  end

  def self.logout key
    @@shells[key] = nil
  end

  private
  def self.shell key
    shell = @@shells[key]
    return if !shell
    if (Time.now - shell[:time] > EXPIRE_TIME)
      @@shells[session[:session_id] + session[:_csrf_token]] = nil
    else
      shell[:shell]
    end
  end

  def self.get_shell name, password, host
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
