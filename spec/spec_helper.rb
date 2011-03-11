require 'active_record'
require 'action_pack'
require 'action_controller'

root = File.dirname(File.dirname(__FILE__))

$LOAD_PATH << "#{root}/lib"
require "#{root}/init"

require "#{root}/spec/setup_test_model.rb"
