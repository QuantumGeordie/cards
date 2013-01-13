Given /^I register a new user$/ do
  post '/reg/', :username => 'uname', :password => 'passypasspass', :first_name => 'first', :last_name => 'last', :email => '3@go.com'
end

Then /^I should see 'Welcome'$/ do
  response_body.should =~ Regexp.new(Regexp.escape('Welcome'))
end

Then /^I logout$/ do
  get '/logout/'
end

Then /^I should see 'logged out'$/ do
  response_body.should =~ Regexp.new(Regexp.escape('logged out'))

end

