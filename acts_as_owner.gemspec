# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{acts_as_owner}
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Cyril Wack"]
  s.cert_chain = ["/Users/cyril/gem-public_cert.pem"]
  s.date = %q{2010-04-12}
  s.description = %q{Simple Rails plugin that allows to operate freely on objects which belong to us.}
  s.email = %q{cyril.wack@gmail.com}
  s.extra_rdoc_files = ["README.rdoc", "lib/acts_as_owner.rb"]
  s.files = ["MIT-LICENSE", "README.rdoc", "Rakefile", "VERSION.yml", "init.rb", "lib/acts_as_owner.rb", "Manifest", "acts_as_owner.gemspec"]
  s.homepage = %q{http://github.com/cyril/acts_as_owner}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Acts_as_owner", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{acts_as_owner}
  s.rubygems_version = %q{1.3.6}
  s.signing_key = %q{/Users/cyril/gem-private_key.pem}
  s.summary = %q{Simple Rails plugin that allows to operate freely on objects which belong to us.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
