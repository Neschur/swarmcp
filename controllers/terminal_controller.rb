def terminal_controller path
  response = SSH.command(session, path)
  {response: response}.to_json
end
