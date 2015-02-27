def panel_erb page = nil
  !session[:user] ? redirect('/') : erb(:"panel/#{page}", layout: :panel)
end

def panel_controller page
  page[0] = '' if page[0] == '/'
  page = 'main' if page.size < 1
  case page
  when 'main'
    @info = SSH.command(session, 'cat /etc/lsb-release')
  end
  panel_erb(page)
end
