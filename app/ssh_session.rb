class SSHSession
  def initialize session, port
    @session = session
    @port = port
  end

  def login user
    socket = get_socket
    socket.puts({
        command: 'login',
        login: user[:name],
        password: user[:password],
        key: key,
        host: 'localhost',
      }.to_json)
    response = socket.gets
    socket.close
    response.strip == 'true'
  end

  def exec command
    socket = get_socket
    socket.puts({
        command: 'exec',
        key: key,
        line: command,
      }.to_json)
    response = []
    while line = socket.gets
      response << line.chop.force_encoding("utf-8")
    end
    socket.close
    response
  end

  def logout
    socket = get_socket
    socket.puts({
        command: 'logout',
        key: key,
      }.to_json)
    response = socket.gets
    socket.close
    response.strip
  end

  private
  def get_socket
    TCPSocket.new('localhost', @port)
  end

  def key
    @session[:session_id]
  end
end
