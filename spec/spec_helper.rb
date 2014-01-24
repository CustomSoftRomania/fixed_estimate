require 'rubygems'
# require 'pry'
begin
  require 'spec'
rescue LoadError
  require 'rspec'
end

$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'i18n'

if ENV["CI"]
  require 'coveralls'
  Coveralls.wear!
end

require 'active_record'
require 'fixed_estimate'

puts "Using ActiveRecord #{ActiveRecord::VERSION::STRING}"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Migrator.migrate("spec/db")

RSpec.configure do |config|

  config.after(:each) do
    [Issue, TimeEntry, TimeEntryActivity].each { |klass| klass.delete_all }
  end
end
