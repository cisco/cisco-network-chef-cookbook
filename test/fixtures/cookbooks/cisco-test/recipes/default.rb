#
# Cookbook Name:: cisco-test
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

#cisco_package 'name-of-package' do
#  action :install
#end

file '/tmp/file_resource.txt' do
  content 'this is a file resource'
  action :create
end

template '/tmp/template_resource.txt' do
  source 'template_resource.erb'
  action :create
end

cookbook_file '/tmp/demo-one-1.0-1.x86_64.rpm' do
  source 'rpm-store/demo-one-1.0-1.x86_64.rpm'
  action :create
end

#cisco_package 'demo-one' do
#  source '/tmp/demo-one-1.0-1.x86_64.rpm'
#  action :install
#end
