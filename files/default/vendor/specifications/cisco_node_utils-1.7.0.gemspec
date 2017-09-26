# -*- encoding: utf-8 -*-
# stub: cisco_node_utils 1.7.0 ruby lib
# stub: ext/mkrf_conf.rb

Gem::Specification.new do |s|
  s.name = "cisco_node_utils".freeze
  s.version = "1.7.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 2.1.0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Rob Gries".freeze, "Alex Hunsberger".freeze, "Glenn Matthews".freeze, "Chris Van Heuveln".freeze, "Rich Wellum".freeze, "Mike Wiebe".freeze, "Jie Yang".freeze, "Sai Chintalapudi".freeze]
  s.date = "2017-05-31"
  s.description = "Utilities for management of Cisco network nodes.\nDesigned to work with Puppet and Chef.\nCurrently supports NX-OS nodes.\n".freeze
  s.email = "cisco_agent_gem@cisco.com".freeze
  s.extensions = ["ext/mkrf_conf.rb".freeze]
  s.files = ["ext/mkrf_conf.rb".freeze]
  s.homepage = "https://github.com/cisco/cisco-network-node-utils".freeze
  s.licenses = ["Apache-2.0".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "2.6.11".freeze
  s.summary = "Utilities for management of Cisco network nodes".freeze

  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_development_dependency(%q<kwalify>.freeze, ["~> 0.7.2"])
      s.add_development_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_development_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_development_dependency(%q<rubocop>.freeze, ["= 0.35.1"])
      s.add_development_dependency(%q<simplecov>.freeze, ["~> 0.9"])
    else
      s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
      s.add_dependency(%q<kwalify>.freeze, ["~> 0.7.2"])
      s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
      s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
      s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
      s.add_dependency(%q<rubocop>.freeze, ["= 0.35.1"])
      s.add_dependency(%q<simplecov>.freeze, ["~> 0.9"])
    end
  else
    s.add_dependency(%q<bundler>.freeze, ["~> 1.7"])
    s.add_dependency(%q<kwalify>.freeze, ["~> 0.7.2"])
    s.add_dependency(%q<minitest>.freeze, ["~> 5.0"])
    s.add_dependency(%q<rake>.freeze, ["~> 10.0"])
    s.add_dependency(%q<rspec>.freeze, ["~> 3.0"])
    s.add_dependency(%q<rubocop>.freeze, ["= 0.35.1"])
    s.add_dependency(%q<simplecov>.freeze, ["~> 0.9"])
  end
end
