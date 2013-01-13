require 'bundler'
Bundler.setup(:default)

require 'sinatra'
require 'rack-flash'
require 'dm-migrations'
require 'dm-validations'
require 'neography'

require 'lib/neo/Neo'
require 'models/Card'

set :session_secret, "tron rides again"
enable :sessions

use Rack::Flash

configure :development do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/db.dev.sqlite3")
  Neo.setup("http://localhost:7474")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/db/db.sqlite3")
  Neo.setup("http://localhost:7474")
end

configure :test do
  # DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/db/db.test.sqlite3")
  DataMapper.setup(:default, "sqlite3:memory")
  Neo.setup("http://localhost:7476")
end

require File.dirname(__FILE__) + '/helpers/helpers.rb'

before do
  @current_user = session['current_user'] 
end

require File.dirname(__FILE__) + '/routes/init.rb'
require File.dirname(__FILE__) + '/models/init.rb'

configure :development, :production do 
  DataMapper.auto_upgrade!
  # DataMapper.auto_migrate!
  # Neo.execute_query("START n=node(*) MATCH n-[r?]-() WHERE ID(n) <> 0 DELETE n,r")
end

configure :test do
  DataMapper.auto_migrate!
end
