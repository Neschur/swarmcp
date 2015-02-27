def terminal_controller path
  response = User.command(session, path)
  {response: response}.to_json
end
