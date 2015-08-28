# cisco-cookbook

#### Table of Contents

1. [Overview](#overview)
2. [Cookbook Description](#cookbook-description)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Resource Reference](#resource-reference)
   * [Resource Catalog (by Technology)](#resource-by-tech)
   * [Resource Catalog (by Name)](#resource-by-name)
6. [Limitations](#limitations)
7. [Development - Guide for contributing to the cookbook](#development)

--
##### Additional References

* Agent Installation
  * [README-agent-install.md](docs/README-agent-install.md) : Agent Installation and Configuration Guide
* User Guides
  * [README-package-provider.md](docs/README-package-provider.md) : Cisco Nexus Package Management using the Package Provider
* Developer Guides
  * [README-develop-types-providers.md](docs/README-develop-types-providers.md) : Developing New cisco-cookbook Resources and Providers

--

## Overview

The `cisco-cookbook` allows a network administrator to manage Cisco Network Elements using Chef. This cookbook bundles a set of Chef Resources, providers, Sample Recipes and installation Tools for effective network management.  The resources and capabilities provided by this cookbook will grow with contributions from Cisco, Chef inc, and the open source community.

The Cisco Network Elements and Operating Systems managed by this cookbook are continuously expanding. Please refer to the [Limitations](#limitations) section for details on currently supported hardware and software. The Limitations section also provides details on compatible Chef client and Chef Server versions.

This GitHub repository contains the latest version of the cisco-cookbook source code. Supported versions of the cisco-cookbook are available at Chef Supermarket. Please refer to [SUPPORT.md](SUPPORT.md) for additional details.

Contributions to this cookbook are welcome. Guidelines on contributions to the cookbook are captured in [CONTRIBUTING.md](CONTRIBUTING.md)

## Cookbook Description

This cookbook enables management of supported Cisco Network Elements using Chef. This cookbook enhances the Chef DSL by introducing new Chef Resources and Providers capable of managing network elements.

The set of supported network element platforms is continuously expanding. Please refer to the [Limitations](#limitations) section for a list of currently supported platforms.

## Setup

#### Chef Server

The `cisco-cookbook` is installed on the Chef server. Please see [The Chef Server](https://docs.chef.io/server/) for information on Chef server setup. See Chef's [knife cookbook site](https://docs.chef.io/knife_cookbook_site.html) for general information on Chef cookbook installation.

#### Chef Client
The Chef Client (agent) requires installation and setup on each device. Agent setup can be performed as a manual process or it may be automated. For more information please see the [README-agent-install.md](docs/README-agent-install.md) document for detailed instructions on agent installation and configuration on Cisco Nexus devices. 

##### Artifacts

As noted in the agent installation guide, these are the current RPM versions for use with cisco-cookbook:

* `bash-shell`: Use [xxxxxx]()
* `guestshell`: Use [xxxxxx]()

##### Gems

The cisco-cookbook has dependencies on a few ruby gems. These gems are already installed in the cookbook as vendored gems so there are no additional steps required for installing these gems. The gems are shown here for reference only:

* [`net_http_unix`](https://rubygems.org/gems/net_http_unix)
* [`cisco_nxapi`](https://rubygems.org/gems/cisco_nxapi)
* [`cisco_node_utils`](https://rubygems.org/gems/cisco_node_utils)

## Usage

Place a dependency on cisco-cookbook in your cookbook's metadata.rb

```ruby
depends 'cisco-cookbook', '~> 0.1'
```

See the recipes directory for example usage of cisco providers and resources.

## Resource Reference

### <a name="resource-by-tech">Resource Catalog (by Technology)<a>

1. Miscellaneous Types
  * [`cisco_command_config`](#type-cisco_command_config)

2. Interface Types
  * [`cisco_interface`](#type-cisco_interface)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)

3. OSPF Types
  * [`cisco_ospf`](#type-cisco_ospf)
  * [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
  * [`cisco_interface_ospf`](#type-cisco_interface_ospf)

4. SNMP Types
  * [`cisco_snmp_community`](#type-cisco_snmp_community)
  * [`cisco_snmp_group`](#type-cisco_snmp_group)
  * [`cisco_snmp_server`](#type-cisco_snmp_server)
  * [`cisco_snmp_user`](#type-cisco_snmp_user)

5. TACACS Types
  * [`cisco_tacacs_server`](#type-cisco_tacacs_server)
  * [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)

6. VLAN Types
  * [`cisco_vlan`](#type-cisco_vlan)
  * [`cisco_vtp`](#type-cisco_vtp)

--
### <a name="resource-by-name">Resource Catalog (by Name)<a>

* [`cisco_command_config`](#type-cisco_command_config)
* [`cisco_interface`](#type-cisco_interface)
* [`cisco_interface_ospf`](#type-cisco_interface_ospf)
* [`cisco_ospf`](#type-cisco_ospf)
* [`cisco_ospf_vrf`](#type-cisco_ospf_vrf)
* [`cisco_snmp_community`](#type-cisco_snmp_community)
* [`cisco_snmp_group`](#type-cisco_snmp_group)
* [`cisco_snmp_server`](#type-cisco_snmp_server)
* [`cisco_snmp_user`](#type-cisco_snmp_user)
* [`cisco_tacacs_server`](#type-cisco_tacacs_server)
* [`cisco_tacacs_server_host`](#type-cisco_tacacs_server_host)
* [`cisco_vlan`](#type-cisco_vlan)
* [`cisco_vtp`](#type-cisco_vtp)

--
### Resource Details

The following resources are listed alphabetically.

### cisco_command_config

The `cisco_command_config` resource allows raw configurations to be managed by chef. It serves as a stopgap until specialized resources are created. It has the following limitations:

* The input message buffer is limited to 500KB. Large configurations are often easier to debug if broken up into multiple smaller resource blocks.
* The cisco_command_config configuration block must use the same syntax as displayed by the show running-config command on the switch. In some cases, configuration commands that omit optional keywords when entered may actually appear with a different syntax when displayed by show running-config; for example, some access-list entries may be configured without a sequence number but yet an implicit sequence number is created regardless. This then creates an idempotency problem because there is a mismatch between show running-config and the manifest. The solution in this case is for the manifest to include explicit sequence numbers for the affected access-list entries.
* Order is important. Some dependent commands may fail if their associated `feature` configuration is not enabled first
* Indentation counts! It implies sub-mode configuration. Use the switch's running-config as a guide and do not indent configurations that are not normally indented. Do not use tabs to indent.
* Inline comments must be prefixed by ! or #
* Negating a submode will also remove configuratons under that submode, without having to specify every submode config statement: `no router ospf RED` removes all configuration under router ospf RED
* Syntax does not auto-complete: use `Ethernet1/1`, not `Eth1/1`
* If a CLI command is rejected during configuration, the resource will abort at that point and will not continue to issue any remaining CLI.  For this reason it is recommended to limit the scope of each instance of this resource.

#### Examples

```ruby
cisco_command_config 'loop42' do
  command '
interface loopback42
  description Peering for AS 42
  ip address 192.168.1.42/24
'
end

cisco_command_config 'route42' do
  command ' ip route 192.168.42.42/32 Null0 '
end
```

#### Parameters

- `command` - The sequence of configuration commands to apply.

### cisco_interface

The `cisco_interface` resource is used to manage general configuration of all
interface types, including ethernet, port-channel, loopback, and SVI (Vlan).

#### Examples

```ruby
cisco_interface 'Ethernet1/1' do
  action :create
  ipv4_address '10.1.1.1'
  ipv4_netmask_length 24
  ipv4_proxy_arp true
  ipv4_redirects true
  shutdown true
  switchport_mode 'disabled'
end

cisco_interface 'Ethernet1/2' do
  action :create
  access_vlan 100
  shutdown false
  switchport_mode 'access'
  switchport_vtp true
end

```

#### Parameters

Note that the setting of the `switchport_mode` parameter influences which of the
other parameters are permitted. Not all interface types support all of the below
parameters.

- `interface_name` - The interface name, in lower case. Defaults to the
   resource name.

- `access_vlan` - The access VLAN ID. Only valid with `switchport_mode`
  set to `access` or `trunk`.

- `description` - Descriptive label for this interface.

- `shutdown` - Set to `true` to administratively shut down this interface,
  `false` to administratively enable this interface.

- `ipv4_address` - IPv4 address to apply to this interface. Requires
  `ipv4_netmask_length`.

- `ipv4_netmask_length` - Netmask length of this interface's IPv4 address.
   Must be a value between `0` and `32`. Requires `ipv4_address`.

- `ipv4_proxy_arp` - Set to `true` to enable Proxy ARP on this interface,
  `false` to disable Proxy ARP.

- `ipv4_redirects` - Set to `false` to disable ICMP redirects on this interface,
  `true` to enable them.

- `negotiate_auto` - Set to `true` or `false` to enable or disable
   autonegotiation of interface speed.

- `switchport_autostate_exclude` - Set to `true` or `false` to exclude or
  include this interface from SVI calculations. Default value: `false`.

- `switchport_mode` - Interface switchport mode. Available options (depending
   on interface type) are 'disabled', 'access', 'tunnel', 'fex_fabric',
   'trunk', 'default'. If set to 'default', the default mode for the interface
   type is used.

- `switchport_vtp` - Set to `true` or `false` to enable or disable VTP on this
  interface. Default value: `false`.

- `svi_autostate` - Enable/disable SVI autostate. Default value: `true`.
   Only applicable to SVI (`vlan`) interfaces.

- `svi_management` - Enable/disable SVI management. Default value: `false`.
   Only applicable to SVI (`vlan`) interfaces.

#### Actions

- `:create` - Creates and/or updates the interface configuration.

- `:destroy` - Unconfigures and/or deletes the interface.

Note that logical interfaces (loopback, SVI, etc.) can be created/destroyed,
while physical interfaces (Ethernet, etc.) can only be configured/unconfigured.
The same actions apply regardless.

### cisco_interface_ospf

The `cisco_interface_ospf` resource is used to manage per-interface OSPF
configuration properties. More broadly applicable OSPF configuration is
managed by the `cisco_ospf` and `cisco_ospf_vrf` resources.

#### Examples

```ruby
cisco_interface_ospf 'Ethernet1/2' do
  action :create
  ospf 'Sample'
  area 200
  cost 200
  dead_interval 200
  hello_interval 200
  message_digest true
  message_digest_encryption_type 'cisco_type_7'
  message_digest_algorithm_type 'md5'
  message_digest_key_id 7
  message_digest_password '088199c89d4a5ee'
  passive_interface true
end
```

#### Parameters

- `interface_name` - The interface name, in lower case. Defaults to the
   resource name.

- `ospf` - The OSPF process name. Required.

- `area` - The OSPF area. Required.

- `cost` - The OSPF link cost for this interface. Default is `0`, meaning to
  calculate cost automatically.

- `dead_interval` - The OSPF dead interval on this interface, in seconds.
  Default value: `40`.

- `hello_interval` - The OSPF hello interval on this interface, in seconds.
  Default value: `10`.

- `message_digest` - Enable or disable message-digest authentication on 
  on the interface. Available options are `true` and `false`. Default value: 
  `false`. 

- `message_digest_algorithm_type` - OSPF message digest algorithm. 
  Default value: `md5`, which is currently the only supported value.

- `message_digest_encryption_type` - Encryption type for the message digest 
  password. Available options are `'cleartext'`, `'3des'`, and `'cisco_type_7'`.
  Default value: `'cleartext'`.

- `message_digest_key_id` - The key ID to use for message digest authentication.
  Valid values are numbers from `0` to `255`, with `0` (the default value)
  indicating message digest authentication is disabled.

- `message_digest_password` - The message digest key (password), in the format
  specified by `message_digest_encryption`.

- `passive_interface` - Set to `true` or `false` to suppress or permit OSPF
  routing updates on this interface.

#### Actions

- `:create` - Creates and/or updates the OSPF configuration on the interface.

- `:destroy` - Removes all OSPF configuration on the interface.

### cisco_ospf

The `cisco_ospf` resource is used to enable/disable OSPF on the switch.
More detailed OSPF configuration is managed by the `cisco_ospf_vrf` and
`cisco_interface_ospf` resources.

#### Examples

```ruby
cisco_ospf 'Sample' do
  action :create
end
```

#### Parameters

- `name` - The name of the OSPF process. Defaults to the resource name.

#### Actions

- `:create` - Enables the given OSPF process, first configuring `feature ospf`
  if necessary.

- `:destroy` - Destroys the given OSPF process. If no OSPF configuration
  remains, will also disable `feature ospf`.

### cisco_ospf_vrf

The `cisco_ospf_vrf` resource is used to manage per-VRF OSPF configuration,
including the `default` VRF.

#### Examples

```ruby
cisco_ospf_vrf 'dark_blue default' do
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

cisco_ospf_vrf 'dark_blue vrf1' do
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
```

#### Parameters

- `ospf` - Name of the parent OSPF process. Defaults to the first word of
   the resource name.

- `vrf` - Name of the VRF to apply OSPF configuration to. Defaults to the
   second word of the resource name. A value of `default` refers to the default
   VRF.

- `auto_cost` - The reference bandwidth, in Mbps, used to calculate interface
  default metrics. Default value: `40000`.

- `default_metric` - The default cost metric for redistributed routes.

- `log_adjacency` - Whether to generate system log messages whenever a neighbor
  changes state. Available options are `'none'`, `'log'`, or `'detail'`.
  Default value: `'none'`.

- `router_id` - IPv4 address to use as a router-id for OSPF.

- `timer_throttle_lsa_start` - LSA generation start interval, in milliseconds.
  Default value: `0`.

- `timer_throttle_lsa_hold` - LSA generation hold interval, in milliseconds.
  Default value: `5000`.

- `timer_throttle_lsa_max` - LSA generation maximum interval, in milliseconds.
  Default value: `5000`.

- `timer_throttle_spf_start` - Initial SPF schedule delay, in milliseconds.
  Default value: `200`.

- `timer_throttle_spf_hold` - Minimum hold time between SPF calculations,
  in milliseconds. Default value: `1000`.

- `timer_throttle_spf_max` - Maximum wait time between SPF calculations, in
  milliseconds. Default value: `5000`.

#### Actions

- `:create` - Enables the given OSPF process for the given VRF.

- `:destroy` - Removes the given VRF from the given OSPF process.

### cisco_package

The `cisco_package` resource is a subclass of the Chef `yum_package` resource.
Unlike `yum_package`, it will always install packages into the NX-OS native
environment, even if the Chef agent is running within Guestshell.

#### Examples

```ruby
cookbook_file '/bootflash/demo-one-1.0-1.x86_64.rpm' do
  owner 'root'
  group 'root'
  mode '0775'
  source 'rpm-store/demo-one-1.0-1.x86_64.rpm'
end

cisco_package 'demo-one' do
  action :install
  source '/bootflash/demo-one-1.0-1.x86_64.rpm'
end
```

#### Parameters

See https://docs.chef.io/resource_package.html

#### Actions

See https://docs.chef.io/resource_package.html

### cisco_snmp_community

The `cisco_snmp_community` resource is used to manage SNMP communities.

#### Examples

```ruby
cisco_snmp_community 'setcom' do
  action :create
  acl 'testcomacl'
  group 'network-admin'
end
```

#### Parameters

- `community` - Name of the SNMP community to manage. Defaults to the
  resource name.

- `acl` - Access control list (ACL) to filter SNMP requests. Default value: '',
  indicating no ACL.

- `group` - SNMP group name. Default value: `network-operator`.

#### Actions

- `:create` - Create or update the given SNMP community.

- `:destroy` - Destroy the given SNMP community.

### cisco_snmp_group

The `cisco_snmp_group` resource is used to manage SNMP groups. Cisco NX-OS
defines SNMP groups based on user roles, so this resource is unable to create
or delete groups but can only be used to validate that the group exists or not.

#### Examples

```ruby
cisco_snmp_group 'network-admin' do
  action :create
end
```

#### Parameters

- `group` - SNMP group name. Defaults to the resource name.

#### Actions

- `:create` - Ensure that the given group exists, or raise an error if not.

- `:destroy` - Ensure that the given group does not exist, or raise an error.

### cisco_snmp_server

The `cisco_snmp_server` resource is used to manage the SNMP server configuration
on a node. There can only be one instance of this resource per node.

#### Examples

```ruby
cisco_snmp_server 'default' do
    aaa_user_cache_timeout 1000
    contact 'user1'
    global_enforce_priv true
    location 'rtp'
    packet_size 2500
    protocol false
    tcp_session_auth false
end
```

#### Parameters

- `name` - Must be `default`.

- `aaa_user_cache_timeout` - Time in seconds before entries in the AAA user
  cache time out. Default value: `3600`.

- `contact` - SNMP system contact (sysContact).

- `global_enforce_priv` - Used to enable/disable SNMP message encryption for
  all users. Default value: `true`.

- `location` - SNMP location (sysLocation).

- `packet_size` - Maximum SNMP packet size. Default value: `1500`.

- `protocol` - Used to enable/disable the SNMP protocol. Default value: `true`.

- `tcp_session_auth` - Used to enable/disable one-time authentication for SNMP
  over a TCP session. Default value: `true`.

#### Actions

- `:update` - Apply changes to the SNMP server configuration as necessary.

### cisco_snmp_user

The `cisco_snmp_user` resource is used to manage SNMP user configuration.

#### Examples

```ruby
cisco_snmp_user 'v3test' do
  groups ['network-admin']
end

cisco_snmp_user 'withengine 128:128:127:127:124:2' do
  auth_password 'Plus+Minus-'
  auth_protocol 'md5'
  groups ['network-admin']
  localized_key false
  priv_password 'Minus-Plus+'
  priv_protocol 'des'
end
```

#### Parameters

- `user` - The username to manage. Defaults to the first word of the resource
  name.

- `engine_id` - SNMP user engineID. Defaults to the second word of the resource
  name, if any, else ''. Valid values are '' or a string consisting of 5 to 32
  colon-separated decimal octets.

- `auth_password` - User authentication password.

- `auth_protocol` - Authentication protocol to use. Available options are
  `'md5'`, `'sha`', or `'none'`. Default value: `md5`.

- `groups` - Array of strings representing the SNMP group(s) that the user
  belongs to.

- `localized_key` - Set to `true` if the `auth_password` and `priv_password`
  are in localized key format, `false` if they are in cleartext format.

- `priv_protocol` - Privacy protocol to use. Available options are `'des'`
  and `'aes128'`. Default value: `des`.

- `priv_password` - User privacy password.

#### Actions

- `:create` - Create or update the given SNMP user.

- `:destroy` - Destroy the given SNMP user.

### cisco_tacacs_server

The `cisco_tacacs_server` resource is used to manage global TACACS+ server
configuration. There can only be one instance of this resource per node.

#### Examples

```ruby
cisco_tacacs_server 'default' do
  action :create
  deadtime 20
  directed_request true
  encryption_password 'test123'
  encryption_type 'clear'
  source_interface 'Ethernet1/2'
  timeout 10
end
```

#### Parameters

- `deadtime` - TACACS+ server deadtime interval, in minutes.

- `directed_request` - Set to true to permit users to specify which server to
  query. Default value: `false`.

- `encryption_password` - Specifies the global TACACS+ server preshared key.

- `encryption_type` - The encryption type for the `encryption_password`.
  Available values are `'clear'`, `'encrypted'`, or `'default'`.

- `source_interface` - Global source interface for all TACACS+ server groups.

- `timeout` - Global timeout interval for TACACS+ servers, in seconds.
  Default value: `5`.

#### Actions

- `:create` - Enable `feature tacacs+` and apply any specified configuration.

- `:update` - Update existing TACACS+ configuration.

- `:destroy` - Disable TACACS+.

### cisco_tacacs_server_host

The `cisco_tacacs_server_host` resource is used to manage per-host TACACS+
configuration.

#### Examples

```ruby
cisco_tacacs_server_host 'testhost' do
  action :create
  encryption_password 'foobarpassword'
  encryption_type 'clear'
  port 66
  timeout 33
end
```

#### Parameters

- `name` - The hostname to manage.

- `encryption_password` - The preshared key for this host.

- `encryption_type` - The encryption type for the `encryption_password`.
  Available values are `'clear'`, `'encrypted'`, or `'default'`.

- `port` - Server port for the host. Default value: `49`.

- `timeout` - Timeout interval for this host, in seconds. Default value: `'0'`,
  indicating to inherit the global TACACS+ server timeout.

#### Actions

- `:create` - Create/update configuration for this TACACS+ server host.

- `:destroy` - Remove all configuration for this host.

### cisco_vlan

The `cisco_vlan` resource is used to manage VLAN configuration.

#### Examples

```ruby
cisco_vlan '220' do
  action :create
  shutdown true
  state 'active'
  vlan_name 'newtest'
end
```

#### Parameters

- `name` - The VLAN ID, in the range 1-4096. Some values are reserved and may
  not be managed by Chef.

- `shutdown` - Whether the VLAN is shut down. Default value: `false`.

- `state` - State of the VLAN. Accepted values are `'active'` and `'suspend'`.
  Default value: `active`.

- `vlan_name` - Descriptive name for the VLAN.

#### Actions

- `:create` - Create/update the specified VLAN.

- `:destroy` - Delete the specified VLAN.

### cisco_vtp

The `cisco_vtp` resource is used to manage VLAN Trunking Protocol (VTP)
configuration. There can only be one instance of this resource per node.

#### Examples

```ruby
cisco_vtp 'default' do
  action :create
  domain 'cisco1234'
  filename 'bootflash:/vlan.dat'
  password 'test1234'
  version 2
end
```

#### Parameters

- `domain` - VTP administrative domain. Required.

- `filename` - VTP file name. Default value: `bootflash:/vlan.dat`

- `password` - VTP domain password.

- `version` - VTP version number. Default value: `1`.

#### Actions

- `:create` - Enable `feature vtp` and apply VTP configuration as requested.

- `:destroy` - Disable VTP.

## Limitations

Minimum Requirements:

* Cisco NX-OS Chef implementation requires Chef version 12.4.1
* Ruby 1.9 or higher (preferably from the Chef full-stack installer)
* Supported Platforms:
  * Cisco Nexus 95xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 93xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 31xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell
  * Cisco Nexus 30xx, OS Version 7.0(3)I2(1), Environments: Bash-shell, Guestshell

## Development

Contributions to cisco-cookbook are welcome and encouraged. Please follow this general workflow for new contributions. See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

1. Fork the cisco-cookbook repository on [Github](https://github.com/chef-partners/cisco-cookbook)
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

--

```text
Copyright (c) 2014-2015 Cisco and/or its affiliates.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
