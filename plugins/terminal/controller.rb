def terminal_controller path
  if path.start_with?('ajax=')
    command = path.sub('ajax=','')
    response = SSH.command(session, command)
    {response: response}.to_json
  else
    render_erb :view
  end
end
