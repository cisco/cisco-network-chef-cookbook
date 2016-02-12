# -*- encoding: utf-8 -*-
# stub: cisco_node_utils 1.2.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cisco_node_utils"
  s.version = "1.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 2.1.0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Alex Hunsberger", "Glenn Matthews", "Chris Van Heuveln", "Mike Wiebe", "Jie Yang", "Rob Gries"]
  s.date = "2016-02-12"
  s.description = "Utilities for management of Cisco network nodes.\nDesigned to work with Puppet and Chef.\nCurrently supports NX-OS nodes.\n"
  s.email = "cisco_agent_gem@cisco.com"
  s.homepage = "https://github.com/cisco/cisco-network-node-utils"
  s.licenses = ["Apache-2.0"]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0")
  s.rubygems_version = "2.5.0"
  s.summary = "Utilities for management of Cisco network nodes"

  s.installed_by_version = "2.5.0" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["~> 5.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rubocop>, ["= 0.35.1"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.9"])
      s.add_runtime_dependency(%q<cisco_nxapi>, [">= 1.0.1", "~> 1.0"])
    else
      s.add_dependency(%q<minitest>, ["~> 5.0"])
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rubocop>, ["= 0.35.1"])
      s.add_dependency(%q<simplecov>, ["~> 0.9"])
      s.add_dependency(%q<cisco_nxapi>, [">= 1.0.1", "~> 1.0"])
    end
  else
    s.add_dependency(%q<minitest>, ["~> 5.0"])
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rubocop>, ["= 0.35.1"])
    s.add_dependency(%q<simplecov>, ["~> 0.9"])
    s.add_dependency(%q<cisco_nxapi>, [">= 1.0.1", "~> 1.0"])
  end
end
