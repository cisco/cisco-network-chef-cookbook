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

cisco_package 'n9000_sample' do
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

# ----------------------------------------------------

Chef::Log.info('Case 3. Cisco Command Config')

cisco_command_config 'cleanup-all' do
  action :update
  command '
    no interface loopback42
    no feature bgp
    no ip route 10.42.42.42/32 Null0'
end

# ----------------------------------------------------

Chef::Log.info('Case 4. Current Cisco Resource & Providers')

cisco_interface_ospf 'loopback2' do
  action :destroy
end

cisco_interface 'loopback2' do
  action :destroy
end

# destroy sub-if first because of mtu dependency
cisco_interface 'Ethernet1/1.1' do
  action :destroy
end

cisco_interface 'Ethernet1/1' do
  switchport_mode 'default'
end

cisco_interface 'Ethernet1/3' do
  switchport_mode 'default'
end

cisco_interface 'Ethernet1/4' do
  switchport_mode 'default'
end

cisco_ospf_vrf 'SAMPLE foo' do
  action :destroy
end

cisco_interface 'Vlan37' do
  action :destroy
end

cisco_vlan '220' do
  action :destroy
end

cisco_ospf 'SAMPLE' do
  action :destroy
end

cisco_tacacs_server_host 'testhost' do
  action :destroy
end

cisco_tacacs_server 'test' do
  action :destroy
end

cisco_vtp 'default' do
  action :destroy
end

cisco_snmp_server 'server' do
  # Implicit defaults will reset all properties
end

# SNMP groups cannot be created or destroyed, only inspected
# cisco_snmp_group 'network-admin' ...

cisco_snmp_community 'setcom' do
  action :destroy
end
