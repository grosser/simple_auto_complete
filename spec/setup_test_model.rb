require 'rubygems'
require 'active_record'
require 'active_record/fixtures'

#create model table
ActiveRecord::Schema.define(:version => 1) do
  create_table "users" do |t|
    t.string "name"
    t.timestamps
  end
end

#create model
class User < ActiveRecord::Base
end

#create controller
class UsersController < ActionController::Base
end