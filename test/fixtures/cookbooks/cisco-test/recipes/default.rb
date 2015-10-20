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

cookbook_file '/bootflash/demo-one-1.0-1.x86_64.rpm' do
  source 'rpm-store/demo-one-1.0-1.x86_64.rpm'
  action :create
end

cisco_package 'demo-one' do
  source '/bootflash/demo-one-1.0-1.x86_64.rpm'
  action :install
end

cisco_command_config 'change interface description' do
  command <<-EOL
    interface Ethernet1/9
      description cookbook-test
  EOL
end

cisco_ospf 'Sample' do
  action :create
end

cisco_ospf 'NotHere' do
  action :destroy
end

cisco_interface 'Ethernet1/1' do
  action :create
  ipv4_address '10.1.1.1'
  ipv4_netmask_length 24
  ipv4_proxy_arp true
  ipv4_redirects true
  shutdown false
  switchport_mode 'disabled'
end

cisco_interface 'Ethernet1/2' do
  action :create
  access_vlan 100
  shutdown false
  switchport_mode 'access'
end

cisco_interface_ospf 'Ethernet1/1' do
  action :create
  ospf 'Sample'
  area 200
  cost 200
  dead_interval 200
  hello_interval 200
  message_digest true
  message_digest_encryption_type '3des'
  message_digest_algorithm_type 'md5'
  message_digest_key_id 7
  message_digest_password '386c0565965f89de'
  passive_interface true
end

cisco_interface_ospf 'Ethernet1/2' do
  action :destroy
end

cisco_ospf_vrf 'Sample default' do
  auto_cost 45000
  default_metric 5
  log_adjacency 'detail'
  timer_throttle_lsa_start 5
  timer_throttle_lsa_hold  5500
  timer_throttle_lsa_max   5600
  timer_throttle_spf_start 250
  timer_throttle_spf_hold  1500
  timer_throttle_spf_max   5500
end

cisco_ospf_vrf 'Sample management' do
  auto_cost 46000
  default_metric 10
  log_adjacency 'log'
  timer_throttle_lsa_start 8
  timer_throttle_lsa_hold  5600
  timer_throttle_lsa_max   5800
  timer_throttle_spf_start 277
  timer_throttle_spf_hold  1700
  timer_throttle_spf_max   5700
end

cisco_ospf_vrf 'Sample novrf' do
  action :destroy
end

cisco_command_config 'create cookbook acl' do
  command <<-EOL
    no ip access-list cookbook
    ip access-list cookbook
      permit ip any any
  EOL
end

cisco_snmp_group 'network-operator' do
  action :create
end

cisco_snmp_community 'testcom' do
  action :create
  acl 'cookbook'
  group 'network-operator'
end

cisco_snmp_community 'nocommunity' do
  action :destroy
end

cisco_snmp_server 'default' do
    aaa_user_cache_timeout 1000
    contact 'user1'
    global_enforce_priv true
    location 'rtp'
    packet_size 2500
    protocol false
    tcp_session_auth false
end

cisco_snmp_user 'withengine 128:128:127:127:124:2' do
  auth_password 'Plus+Minus-'
  auth_protocol 'md5'
  localized_key false
  priv_password 'Minus-Plus+'
  priv_protocol 'des'
end

cisco_tacacs_server 'default' do
  action :create
  deadtime 20
  directed_request true
  encryption_password 'test123'
  encryption_type 'clear'
  source_interface 'Ethernet1/1'
  timeout 1
end

cisco_tacacs_server_host 'testhost' do
  action :create
  encryption_password 'foobarpassword'
  encryption_type 'clear'
  port 66
  timeout 1
end

cisco_vlan '220' do
  action :create
  shutdown false
  state 'active'
  vlan_name 'cookbook'
end

cisco_vtp 'default' do
  action :create
  domain 'cisco1234'
  filename 'bootflash:/vlan.dat'
  password 'test1234'
  version 2
end
