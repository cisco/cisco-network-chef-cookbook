#
# Cookbook Name:: cisco-cookbook
# Recipe:: demo_cleanup
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
#
# This is just a cleanup for the demo_install recipe.
# ----------------------------------------------------

Chef::Log.info('Case 1. Package Mgmt: Cisco RPM, Cisco RPM Patch')
cisco_package 'bgp-dev' do
  action :remove
end

cisco_package 'CSCuxdublin' do
  action :remove
end

# ----------------------------------------------------

Chef::Log.info('Case 2. Package Mgmt: 3rd Party RPM')

service 'demo-one' do
  action :stop
end

cisco_package 'demo-one' do
  action :remove
end
