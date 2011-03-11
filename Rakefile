task :spec do
  sh "bundle exec rspec spec"
end

task :rails2 do
  sh "cd spec/rails2 && bundle exec rspec ../../spec"
end

task :default do
  sh "rake spec && rake rails2"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name =  'simple_autocomplete'
    gem.summary = "Rails: Simple, customizable, unobstrusive - auto complete"
    gem.email = "grosser.michael@gmail.com"
    gem.homepage = "http://github.com/grosser/#{gem.name}"
    gem.authors = ["Michael Grosser"]
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end
