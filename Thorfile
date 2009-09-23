require 'thor/rake_compat'
require 'spec/rake/spectask'

GEM = "robot-army-git-deploy"

class Default < Thor
  include Thor::RakeCompat

  Spec::Rake::SpecTask.new(:spec) do |t|
    t.libs << 'lib'
    # t.spec_opts = ['--options', 'spec/spec.opts']
    t.spec_files = FileList['spec/**/*_spec.rb']
  end

  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.libs << 'lib'
    # t.spec_opts = ['--options', 'spec/spec.opts']
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
    t.rcov_dir = 'rcov'
  end

  begin
    require 'jeweler'
    Jeweler::Tasks.new do |s|
      s.name = GEM
      s.rubyforge_project = GEM
      s.platform = Gem::Platform::RUBY
      s.summary = "Robot Army deployment with git repositories"
      s.email = "brian@wesabe.com"
      s.homepage = "http://github.com/wesabe/robot-army-git-deploy"
      s.description = "Robot Army deployment with git repositories"
      s.authors = ['Brian Donovan']
      s.require_path = 'lib'
      s.bindir = 'bin'
      s.files = %w(LICENSE README.markdown Rakefile) + Dir.glob("{bin,lib,specs}/**/*")
      s.add_dependency("robot-army", [">= 0.1.7"])
      s.add_dependency("thor", [">= 0.11.3"])
      s.add_dependency("grit", ["> 0.0.0"])
      s.add_dependency("highline", ["> 0.0.0"])
    end
  rescue LoadError
    puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
  end
end

