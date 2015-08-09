# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "net_http_unix"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jeff McCune"]
  s.date = "2014-11-25"
  s.description = "Wrapper around Net::HTTP with AF_UNIX support"
  s.email = ["jeff@puppetlabs.com"]
  s.executables = ["net_http_unix"]
  s.files = ["bin/net_http_unix"]
  s.homepage = "http://github.com/puppetlabs/net_http_unix"
  s.licenses = ["Apache 2.0"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.29"
  s.summary = "Wrapper around Net::HTTP with AF_UNIX support"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end
