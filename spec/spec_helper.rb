# ---- requirements
require 'rubygems'
require 'spec'
require 'mocha'
require 'active_record'
require 'action_pack'
require 'action_controller'

$LOAD_PATH << "lib"

# ---- rspec
Spec::Runner.configure do |config|
  config.mock_with :mocha
end

require "init"
load "spec/setup_test_model.rb"