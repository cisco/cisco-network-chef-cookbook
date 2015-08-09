# CiscoNxapi - Cisco NX-API Utilities

The CiscoNxapi gem provides utilities for communicating with Cisco network
nodes running NX-OS 7.0(3)I2(1) and later via the NX-API management API.

This is a low-level library for direct communication with NX-API.
For a greater level of abstraction, use the [CiscoNodeUtils gem](https://rubygems.org/gems/cisco_node_utils).

## Installation

To install the CiscoNxapi gem, use the following command:

    $ gem install cisco_nxapi

(Add `sudo` if you're installing under a POSIX system as root)

Alternatively, if you've checked the source out directly, you can call
`rake install` from the root project directory.

## Examples

This gem can be used directly on a Cisco device (as used by Puppet and Chef)
or can run on a workstation and point to a Cisco device (as used by the
included minitest suite).

### Usage on a Cisco device

```ruby
require 'cisco_nxapi'

client = CiscoNxapi::NxapiClient.new()

client.show("show version")

client.config(["interface ethernet1/1",
               "description Managed by NX-API",
               "no shutdown"])
```

### Remote usage

```ruby
require 'cisco_nxapi'

client = CiscoNxapi::NxapiClient.new("n3k.mycompany.com",
                                     "username", "password")

client.show("show version")

client.config(["interface ethernet1/1",
               "description Managed by NX-API",
               "no shutdown"])
```

## Changelog

See [CHANGELOG](CHANGELOG.md) for a list of changes.

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## License

Copyright (c) 2013-2015 Cisco and/or its affiliates.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
