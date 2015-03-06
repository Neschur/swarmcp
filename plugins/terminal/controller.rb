def terminal_controller path
  if path.start_with?('ajax=')
    command = path.sub('ajax=','')
    response = @ssh_session.exec(command)
    {response: response}.to_json
  else
    render_erb :view
  end
end
