def panel_erb page = nil
  !session[:user] ? redirect('/') : erb(:"panel/#{page || 'main'}", layout: :panel)
end

def panel_controller page
  page[0] = '' if page[0] == '/'
  page = 'main' if page.size < 1
  case page
  when 'main'
    @info = User.command(session, 'cat /etc/lsb-release')
  end
  panel_erb(page)
end
