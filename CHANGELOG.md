# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

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

[unreleased]: https://github.com/cisco/cisco-network-chef-cookbook/compare/master...develop
[1.0.0]: https://github.com/cisco/cisco-network-chef-cookbook/compare/v1.0.0...v0.9.0

