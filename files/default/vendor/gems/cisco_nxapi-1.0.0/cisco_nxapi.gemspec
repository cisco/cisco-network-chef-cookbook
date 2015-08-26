# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cisco_nxapi/version'

Gem::Specification.new do |spec|
  spec.name          = 'cisco_nxapi'
  spec.version       = CiscoNxapi::VERSION
  spec.authors       = ['Alex Hunsberger', 'Glenn Matthews',
                        'Chris Van Heuveln', 'Mike Wiebe', 'Jie Yang']
  spec.email         = 'cisco_agent_gem@cisco.com'
  spec.summary       = 'Utilities for working with Cisco NX-OS NX-API'
  spec.description   = <<-EOF
Utilities for working with the Cisco NX-OS NX-API.
Designed to be used with Puppet and Chef and the cisco_node_utils gem.
  EOF
  spec.license       = 'Apache-2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'minitest', '>= 2.5.1', '< 5.0.0'
  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '>= 0.32'
  spec.add_runtime_dependency 'net_http_unix', '~> 0.2', '>= 0.2.1'
end
