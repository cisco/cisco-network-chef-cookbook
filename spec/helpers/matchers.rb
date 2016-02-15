if defined?(ChefSpec)
  chefspec_version = Gem.loaded_specs['chefspec'].version
  if chefspec_version < Gem::Version.new('4.1.0')
    define_method = ChefSpec::Runner.method(:define_runner_method)
  else
    define_method = ChefSpec.method(:define_matcher)
  end

  define_method.call :cisco_package

  def create_cisco_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('cisco_package', :install, resource_name)
  end

  def remove_cisco_package(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new('cisco_package', :remove, resource_name)
  end
end
