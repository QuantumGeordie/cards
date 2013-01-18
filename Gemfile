source :rubygems

gem "sinatra", "1.2.6"
gem "dm-core"
gem "datamapper"
gem "dm-migrations"
gem 'dm-validations'
gem 'rack'
gem 'rack-flash'
gem 'rake'
gem 'neography'
gem 'awesome_print'
gem 'text'

group :test do
  gem "webrat"
  gem "rspec", "2.6.0"
  gem "rack-test"
  gem "cucumber"
end

group :production do
  gem 'dm-postgres-adapter'
end
group :development, :test do
  gem 'dm-sqlite-adapter'
end
