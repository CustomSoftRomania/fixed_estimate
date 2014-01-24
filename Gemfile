source 'http://rubygems.org'

gem 'rake'

group :development, :test do
  gem 'rspec'
  gem 'sqlite3'

  gem 'activesupport', '3.2.16'
  gem 'activerecord', '3.2.16'
  gem 'activemodel', '3.2.16'

  gem 'pry'

  if ENV["CI"]
    gem 'coveralls', require: false
  end
end
