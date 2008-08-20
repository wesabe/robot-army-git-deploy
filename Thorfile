require 'rubygems'
require 'rubygems/specification'
require 'thor/tasks'

Dir[File.join(File.dirname(__FILE__), 'examples', '*.rb')].each {|f| require f}

GEM = "robot-army-git-deploy"
GEM_VERSION = "0.0.1"
AUTHOR = "Brian Donovan"
EMAIL = "brian@wesabe.com"
HOMEPAGE = "http://github.com/wesabe/robot-army-git-deploy"
SUMMARY = "Robot Army deployment with git repositories"
PROJECT = "robot-army"

SPEC = Gem::Specification.new do |s|
  s.name = GEM
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.summary = SUMMARY
  s.description = s.summary
  s.author = AUTHOR
  s.email = EMAIL
  s.homepage = HOMEPAGE
  s.rubyforge_project = PROJECT
  s.date = Time.now.strftime('%Y-%m-%d')
  
  s.require_path = 'lib'
  s.files = %w(LICENSE README.markdown Rakefile) + Dir.glob("{bin,lib,specs}/**/*")
  s.add_dependency("robot-army", [">= 0.1.1"])
  s.add_dependency("thor", ["> 0.0.0"])
  s.add_dependency("grit", ["> 0.0.0"])
  s.add_dependency("highline", ["> 0.0.0"])
end

class Default < Thor
  # Set up standard Thortasks
  spec_task(Dir["spec/**/*_spec.rb"])
  install_task SPEC
  
  desc "make_spec", "make a gemspec file"
  def make_spec
    File.open("#{GEM}.gemspec", "w") do |file|
      file.puts SPEC.to_ruby
    end    
  end
end
