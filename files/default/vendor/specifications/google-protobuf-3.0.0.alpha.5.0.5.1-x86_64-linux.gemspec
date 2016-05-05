# -*- encoding: utf-8 -*-
# stub: google-protobuf 3.0.0.alpha.5.0.5.1 x86_64-linux lib

Gem::Specification.new do |s|
  s.name = "google-protobuf"
  s.version = "3.0.0.alpha.5.0.5.1"
  s.platform = "x86_64-linux"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Protobuf Authors"]
  s.date = "2016-05-04"
  s.description = "Protocol Buffers are Google's data interchange format."
  s.email = "protobuf@googlegroups.com"
  s.homepage = "https://developers.google.com/protocol-buffers"
  s.licenses = ["BSD"]
  s.rubygems_version = "2.4.6"
  s.summary = "Protocol Buffers"

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake-compiler-dock>, [">= 0"])
      s.add_development_dependency(%q<rake-compiler>, [">= 0"])
      s.add_development_dependency(%q<test-unit>, [">= 0"])
      s.add_development_dependency(%q<rubygems-tasks>, [">= 0"])
    else
      s.add_dependency(%q<rake-compiler-dock>, [">= 0"])
      s.add_dependency(%q<rake-compiler>, [">= 0"])
      s.add_dependency(%q<test-unit>, [">= 0"])
      s.add_dependency(%q<rubygems-tasks>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake-compiler-dock>, [">= 0"])
    s.add_dependency(%q<rake-compiler>, [">= 0"])
    s.add_dependency(%q<test-unit>, [">= 0"])
    s.add_dependency(%q<rubygems-tasks>, [">= 0"])
  end
end
