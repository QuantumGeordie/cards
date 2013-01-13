require File.join(File.dirname(__FILE__), '..', 'app.rb')

require 'rack/test'
set :environment, :test

RSpec.configure do |config|
  config.before(:each) do 
    DataMapper.auto_migrate! 
    Neo.execute_query("START n=node(*) MATCH n-[r?]-() WHERE ID(n) <> 0 DELETE n,r")
  end
end

