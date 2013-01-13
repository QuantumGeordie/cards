helpers do
  
  include Rack::Utils
  alias_method :h, :escape_html

  def HelperTest(text)
    "helper test #{text}"
  end
 
  def DayOfWeek(date)
    day_of_week = case date.wday
      when 0 then "Sunday"
      when 1 then "Monday"
      when 2 then "Tuesday"
      when 3 then "Wednesday"
      when 4 then "Thursday"
      when 5 then "Friday"
      when 6 then "Saturday"
      else "unknown day"
    end

    day_of_week
  end    
  
  def EncryptClearText(clear_text)
    Digest::SHA1.hexdigest(clear_text)
  end
  
  def Login(u, p)
    p_crypt = EncryptClearText(p)

    user = User.first(:username => u)
    
    if user == nil
      setCurrentUser(nil)
      return nil
    end

    if user.password != p_crypt
      user = nil
    end

    setCurrentUser(user)
    
    return user
  end
  
  def Logout
    setCurrentUser(nil)
  end
  
  def setCurrentUser(user)
    session[:current_user] = user
  end
  
  def getCurrentUser
    return session[:current_user]
  end
end


  
