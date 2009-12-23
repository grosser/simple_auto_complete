require 'simple_autocomplete'
ActionController::Base.send :extend, SimpleAutocomplete::ControllerMethods
ActiveRecord::Base.send :extend, SimpleAutocomplete::RecordMethods