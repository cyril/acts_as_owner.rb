Gem::Specification.new do |s|
  s.name        = "acts_as_owner"
  s.version     = YAML.load_file("VERSION.yml").values.join('.')
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Cyril Wack"]
  s.email       = ["contact@cyril.io"]
  s.homepage    = "http://github.com/cyril/acts_as_owner"
  s.summary     = %q{Simple ownership solution for Rails.}
  s.description = %q{Simple Rails plugin that allows to operate freely on objects which belong to us.}

  s.rubyforge_project = "acts_as_owner"

  s.add_runtime_dependency "railties", ">= 3.0.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]
end
