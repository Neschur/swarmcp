class User
  def self.login user, session
    socket = get_socket
    socket.puts({
        command: 'login',
        login: user[:name],
        password: user[:password],
        key: key(session),
        host: 'localhost',
      }.to_json)
    response = socket.gets
    socket.close
    response.strip == 'true'
  end

  def self.command session, line
    socket = get_socket
    socket.puts({
        command: 'exec',
        key: key(session),
        line: line,
      }.to_json)
    response = []
    while line = socket.gets
      response << line.chop.force_encoding("utf-8")
    end
    socket.close
    response
  end

  def self.logout session
    socket = get_socket
    socket.puts({
        command: 'logout',
        key: key(session),
      }.to_json)
    response = socket.gets
    socket.close
    response.strip
  end

  private
  def self.get_socket
    TCPSocket.new('localhost', 2626)
  end

  def self.key session
    session[:session_id]
  end
end
