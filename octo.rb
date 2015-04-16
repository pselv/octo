require 'json'
require 'mongoid'
require 'pry'
# Load path and gems/bundler
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))
root = File.expand_path(File.dirname(__FILE__))


require "bundler"
Bundler.require

# Local config
require "find"

Mongoid.load!("config/mongoid.yml", :development)

%w{config/initializers lib}.each do |load_path|
  Find.find(load_path) { |f|
    require f unless f.match(/\/\..+$/) || File.directory?(f)
  }
end
Dir["#{root}/models/**/*.rb"].each do |file|
  require file
end

Dir["#{root}/app/**/*.rb"].each do |file|
  require file
end

