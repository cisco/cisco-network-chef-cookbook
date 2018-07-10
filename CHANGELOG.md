# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

**NOTE:** Starting in release `9.2(1)` and onward, installing the chef-client into the `bash-shell` hosting environment is no longer supported.

The chef-client software must be installed on a Cisco Nexus platform in the `Guestshell` (the Linux container environment running CentOS). This provides a secure, open execution environment that is decoupled from the host.


### New feature support
*

### Added
*

### Removed
* Support for chef-client install into the `bash-shell` hosting environment. This is the native WRL Linux environment underlying NX-OS.

## [1.2.1] - 2017-09-26

### Added
- Update the cisco_node_utils vendored gem to version [1.7.0](https://github.com/cisco/cisco-network-node-utils/blob/develop/CHANGELOG.md#v170).

### Removed
- `grpc` and `google_protobuf` vendored gems.

## [1.2.0] - 2017-04-04

### Added
- Enabled all providers on the N9k-F platform.
- Enabled cisco_vtp support on N5k and N6k platforms.

## [1.1.2] - 2016-02-24
### Added
- Download link for Nexus 5000 and Nexus 6000 Open Agent Container (OAC).
- OAC programmability guide links.

## [1.1.1] - 2016-02-16
### Fixed
- Update README-agent-install.md to reflect higher minimum memory requirement for guestshell
- Update README-agent-install.md to include workaround for certificate problems in bash-shell

## [1.1.0] - 2016-02-12
### Added
- Extended cisco_interface (@robert-w-gries)
  - encapsulation dot1q
  - mtu
  - switchport trunk allowed vlan
  - switchport trunk native vlan
  - vrf member
- Travis-CI integration, currently running Rubocop and Foodcritic validation (@glennmatthews)
- Documentation workflow map to guide users, developers, and maintainers to the proper docs (@mikewiebe)
- Doc updates for examples, templates, and install instructions (@chrisvanheuveln)
- Test Kitchen integration (@adamleff, @edolnx)
- Serverspec tests (@adamleff)
- Added support for Chef 12.6.0 (@adamleff)
- Updated documentation with platform support for providers and required software versions (@robert-w-gries)

### Fixed
- Code changes to satisfy Rubocop. (@glennmatthews)
- Updated cisco ohai plugin to use correct load path for vendor gems (Alex Hunsberger)
- Cleaned up demo recipes for N5k, N6k, and N7k platforms (@robert-w-gries)

## [1.0.1] - 2015-09-21
### Fixed
- Fixed broken documentation links.

## [1.0.0] - 2015-08-28
### Added
- Added README-maintainers.md

### Fixed
- Several cases where providers would log an error message on receiving invalid input but would not actually raise an exception.
- Ospf router-id default processing.
- Added dotted-decimal munging for area in resource_cisco_interface_ospf
- Modified template placeholder names to meet lint reqs
- cisco_interface_ospf fix for area property when Fixnum is used
- cisco_ospf idempotency fix
- Moved misc READMEs to /docs

## [0.9.0] - 2015-06-22
### Added
- Initial release of cisco-cookbook for chef, supporting Cisco NX-OS software release 7.0(3)I2(1) on Cisco Nexus switch platforms: N95xx, N93xx, N30xx and N31xx.
- Please note: 0.9.0 is an EFT pre-release for a limited audience with access to NX-OS 7.0(3)I2(1). Additional code changes may occur in 0.9.x prior to the final 1.0.0 release.

[1.2.1]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v0.9.0...v1.0.0

