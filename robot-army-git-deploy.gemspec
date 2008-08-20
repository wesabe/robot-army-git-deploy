Gem::Specification.new do |s|
  s.name = %q{robot-army-git-deploy}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Brian Donovan"]
  s.date = %q{2008-08-19}
  s.description = %q{Robot Army deployment with git repositories}
  s.email = %q{brian@wesabe.com}
  s.extra_rdoc_files = ["README.markdown", "LICENSE"]
  s.files = ["LICENSE", "README.markdown", "Rakefile", "lib/robot-army-git-deploy", "lib/robot-army-git-deploy/git_deployer.rb", "lib/robot-army-git-deploy.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/wesabe/robot-army-git-deploy}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{robot-army}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{Robot Army deployment with git repositories}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<robot-army>, [">= 0.1.1"])
      s.add_runtime_dependency(%q<thor>, ["> 0.0.0"])
      s.add_runtime_dependency(%q<grit>, ["> 0.0.0"])
    else
      s.add_dependency(%q<robot-army>, [">= 0.1.1"])
      s.add_dependency(%q<thor>, ["> 0.0.0"])
      s.add_dependency(%q<grit>, ["> 0.0.0"])
    end
  else
    s.add_dependency(%q<robot-army>, [">= 0.1.1"])
    s.add_dependency(%q<thor>, ["> 0.0.0"])
    s.add_dependency(%q<grit>, ["> 0.0.0"])
  end
end
