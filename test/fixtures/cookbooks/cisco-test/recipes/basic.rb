#
# Cookbook Name:: cisco-test
# Recipe:: basic
#
# Copyright (c) 2015-2016, Cisco, Apache 2.0

file '/tmp/file_resource.txt' do
  content 'this is a file resource'
  action :create
end

template '/tmp/template_resource.txt' do
  source 'template_resource.erb'
  action :create
end
