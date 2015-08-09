# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'net_http_unix/version'

Gem::Specification.new do |spec|
  spec.name          = "net_http_unix"
  spec.version       = NetHttpUnix::VERSION
  spec.authors       = ["Jeff McCune"]
  spec.email         = ["jeff@puppetlabs.com"]
  spec.description   = %q{Wrapper around Net::HTTP with AF_UNIX support}
  spec.summary       = %q{Wrapper around Net::HTTP with AF_UNIX support}
  spec.homepage      = "http://github.com/puppetlabs/net_http_unix"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "yard"
end
