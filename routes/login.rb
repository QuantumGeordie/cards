post '/login/?' do
  u = params[:username] if params[:username]
  p = params[:password] if params[:password]

  p ||= ''

  @current_user = Login(u, p)
  
  if @current_user
    flash[:notice] = 'welcome ' + @current_user.first_name
  else
    flash[:error] = 'login failure!'
  end
  
  redirect '/'
end

get '/reg/?' do
  erb :reg
end

post '/reg/?' do
  u = params[:username] ? params[:username] : ''
  p = params[:password] ? params[:password] : ''
  f = params[:first_name] ? params[:first_name] : ''
  l = params[:last_name] ? params[:last_name] : ''
  e = params[:email] ? params[:email] : ''
  p_crypt = EncryptClearText(p)
  
  params[:password] = p_crypt
  
  user = User.new(:username => u, :password => p_crypt, :first_name => f, :last_name => l, :email => e)
  
  if user.save
    @current_user = Login(u, p)
    if @current_user
      flash[:notice] = "Registration Successfull! Welcome, #{user.first_name}"
    else
      flash[:error] = "Login failed following registration!"  
    end
  else
    session[:current_user] = nil
    flash[:error] = "Registration Failure!"
  end
  
  redirect '/'
end

get '/logout/?' do
  Logout()
  flash[:notice] = "Successfully logged out!"
  redirect '/'
end
