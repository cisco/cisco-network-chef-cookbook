# -*- encoding: utf-8 -*-
# stub: cisco_node_utils 1.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "cisco_node_utils"
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Alex Hunsberger", "Glenn Matthews", "Chris Van Heuveln", "Mike Wiebe", "Jie Yang"]
  s.date = "2015-08-26"
  s.description = "Utilities for management of Cisco network nodes.\nDesigned to work with Puppet and Chef.\nCurrently supports NX-OS nodes.\n"
  s.email = "cisco_agent_gem@cisco.com"
  s.licenses = ["Apache-2.0"]
  s.rubygems_version = "2.2.2"
  s.summary = "Utilities for management of Cisco network nodes"

  s.installed_by_version = "2.2.2" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<minitest>, ["< 5.0.0", ">= 2.5.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.7"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<rubocop>, [">= 0.32"])
      s.add_runtime_dependency(%q<cisco_nxapi>, ["~> 1.0"])
    else
      s.add_dependency(%q<minitest>, ["< 5.0.0", ">= 2.5.1"])
      s.add_dependency(%q<bundler>, ["~> 1.7"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<rubocop>, [">= 0.32"])
      s.add_dependency(%q<cisco_nxapi>, ["~> 1.0"])
    end
  else
    s.add_dependency(%q<minitest>, ["< 5.0.0", ">= 2.5.1"])
    s.add_dependency(%q<bundler>, ["~> 1.7"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<rubocop>, [">= 0.32"])
    s.add_dependency(%q<cisco_nxapi>, ["~> 1.0"])
  end
end
