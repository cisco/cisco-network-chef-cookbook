#
# Cookbook Name:: cisco-cookbook
# Recipe:: demo_patch_install
#
# Copyright (c) 2014-2016 Cisco and/or its affiliates.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# In our recipes, due to the number of different parameters, we prefer to align
# the arguments in a single column rather than following rubocop's style.

# Uncomment the following resources to run on N3k, N9k-F, or N9k
cookbook_file '/bootflash/CSCuxdublin-1.0.0-7.0.3.I3.1.lib32_n9000.rpm' do
  owner  'root'
  group  'root'
  mode   '0775'
  source 'rpm-store/CSCuxdublin-1.0.0-7.0.3.I3.1.lib32_n9000.rpm'
end

cisco_package 'CSCuxdublin' do
  action :install
  # action :remove
  # package_settings {'target' => 'host'}
  source '/bootflash/CSCuxdublin-1.0.0-7.0.3.I3.1.lib32_n9000.rpm'
end

Chef::Log.info('Install third party package:')

cookbook_file '/bootflash/demo-one-1.0-1.x86_64.rpm' do
  owner  'root'
  group  'root'
  mode   '0775'
  source 'rpm-store/demo-one-1.0-1.x86_64.rpm'
end

cisco_package 'demo-one' do
  # demo-one-1.0-1.x86_64.rpm:
  #  /usr/bin/demo-one            # binary
  #  /etc/demo-one/demo-one.conf  # configuration file
  #  /tmp/demo-one.log            # writes a timestamp to log
  action :install
  source '/bootflash/demo-one-1.0-1.x86_64.rpm'
end

# Chef::Log.info('Install and start a service:')

# # TODO: Add platform check to distinguish between native and guestshell
# # cookbook_file '/usr/lib/systemd/system/demo-one.service' do
cookbook_file '/etc/init.d/demo-one' do
  owner  'root'
  group  'root'
  mode   '0775'
  source 'demo-one.initd'
  # source 'demo-one.service'
end

service 'demo-one' do
  # see above note: This is not compatible with GS
  action :start
end
