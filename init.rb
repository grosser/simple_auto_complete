ActionController::Base.send :extend, Grosser::Autocomplete::ControllerMethods
ActiveRecord::Base.send :extend, Grosser::Autocomplete::RecordMethods