source 'https://rubygems.org'

group :test do
  gem 'rspec'
end

group :development do
  gem 'pry'
  gem 'guard'
  gem 'guard-rspec', :require => false
  gem 'rspec-nc' if File.exists? '/mach_kernel'
end

# Specify your gem's dependencies in net_http_unix.gemspec
gemspec

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
# vim:ft=ruby
