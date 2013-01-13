require File.dirname(__FILE__) + '/spec_helper'

describe 'Card Exchange' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end 

  describe 'user stuff' do
    
    it 'should create a single user and count it properly' do
      user = User.create(:username   => 'uname',
                         :password   => 'password',
                         :first_name => 'first',
                         :last_name  => 'last',
                         :email      => 'email@test.com')
   
      users = User.count.should == 1
    end
    
    it 'should construct a full name' do
       user = User.create(:username   => 'uname',
                         :password   => 'password',
                         :first_name => 'first',
                         :last_name  => 'last',
                         :email      => 'email@test.com')
   
      user.full_name.should == 'first last'
    
    end
    
    it 'should throw some errors when validations are not met' do
      users_at_start = User.count
      
      u = User.new(:username   => 'uname2',
                         :first_name => 'first',
                         :last_name  => 'last',
                         :email      => 'email2@test.com')
                         
      u.save.should == false
      
      User.count.should == users_at_start
      
      u = User.new(:username   => 'uname2',
                         :password   => 'password2',
                         :first_name => 'first',
                         :last_name  => 'last',
                         :email      => 'email2@test')
     
      u.save.should == false
      
      User.count.should == users_at_start
    end
    
    it 'should login' do
      user = User.create(:username   => 'uname',
                         :password   => Digest::SHA1.hexdigest('password'),
                         :first_name => 'first',
                         :last_name  => 'last',
                         :email      => 'email@test.com')
 
      post '/login/',  :username => 'uname', :password => 'password'   
      c_u = last_request.session[:current_user]
      c_u.should_not == nil
      c_u.last_name.should == user.last_name
      
      get '/'
      last_response.status.should == 200
      c_u = last_request.session[:current_user]
      c_u.should_not == nil
      c_u.last_name.should == user.last_name
      
    end

    it 'should fail to login' do
      user = User.create(:username   => 'uname',
                         :password   => Digest::SHA1.hexdigest('password'),
                         :first_name => 'first',
                         :last_name  => 'last',
                         :email      => 'email@test.com')
 
      post '/login/',  :username => 'uname', :password => 'wrong password'   
      c_u = last_request.session[:current_user]
      c_u.should == nil
      
      get '/'
      c_u = last_request.session[:current_user]
      c_u.should == nil
      
      post '/login/',  :username => 'other_uname', :password => 'password'   
      c_u = last_request.session[:current_user]
      c_u.should == nil
      
      post '/login/'
      c_u = last_request.session[:current_user]
      c_u.should == nil
      
    end

    it 'should register and login' do
      post '/reg/', :username => 'uname', :password => 'passypasspass', :first_name => 'first', :last_name => 'last', :email => '3@go.com'

      c_u = last_request.session[:current_user]
      c_u.should_not == nil
      last_request.env['x-rack.flash'][:notice].should include("Welcome")
      c_u.email.should == '3@go.com'
    end

    it 'should logout' do
      post '/reg/', :username => 'uname', :password => 'passypasspass', :first_name => 'first', :last_name => 'last', :email => '3@go.com'
      c_u = last_request.session[:current_user]
      c_u.should_not == nil
      
      get '/logout/'
      c_u = last_request.session[:current_user]
      c_u.should == nil
      
    
    end
  
  end # user stuff

  describe 'basic test functionality' do 

    it 'should run a single test in test environment' do
      settings.environment.should == :test
    end

    it 'should return OK/200 status' do
      get '/'
      last_response.status.should == 200
    end

  end  # end basic test functionality
end
