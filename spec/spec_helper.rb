# ---- requirements
require 'rubygems'
require 'spec'
require 'mocha'
require 'activerecord'
require 'actionpack'
require 'action_controller'

$LOAD_PATH << File.expand_path("../lib", File.dirname(__FILE__))


# ---- rspec
Spec::Runner.configure do |config|
  config.mock_with :mocha
end


# ---- load database
RAILS_ENV = "test"
ActiveRecord::Base.configurations = {"test" => {
  :adapter => "sqlite3",
  :database => ":memory:",
}.with_indifferent_access}

ActiveRecord::Base.logger = Logger.new(File.directory?("log") ? "log/#{RAILS_ENV}.log" : "/dev/null")
ActiveRecord::Base.establish_connection(:test)


# ---- setup environment/plugin
require File.expand_path("../init", File.dirname(__FILE__))
load File.expand_path("setup_test_model.rb", File.dirname(__FILE__))


# ---- fixtures
Spec::Example::ExampleGroupMethods.module_eval do
  def fixtures(*tables)
    dir = File.expand_path("fixtures", File.dirname(__FILE__))
    tables.each{|table| Fixtures.create_fixtures(dir, table.to_s) }
  end
end