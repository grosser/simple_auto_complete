require 'rake' 
require 'rake/rdoctask' 

desc 'Default: run spec.'
task :default => :spec

desc "Run all specs in spec directory"
task :spec do |t|
  options = "--colour --format progress --loadby --reverse"
  files = FileList['spec/**/*_spec.rb']
  system("spec #{options} #{files}")
end

desc 'Generate documentation for autocomplete plugin.' 
Rake::RDocTask.new(:rdoc) do |rdoc| 
  rdoc.rdoc_dir = 'rdoc' 
  rdoc.title    = 'Auto Complete' 
  rdoc.options << '--line-numbers' << '--inline-source' 
  rdoc.rdoc_files.include('README') 
  rdoc.rdoc_files.include('lib/**/*.rb') 
end
