# Managing Packages with the cisco_package Provider

#### Table of Contents

1. [Overview](#overview)
2. [Syntax](#syntax)
3. [Examples](examples)
4. [References](#references)

## <a name="overview">Overview</a>

This document describes the **cisco_package** provider for Chef, which provides package management for Cisco NX-OS RPM packages. These RPMs target the NX-OS host environment.

<i>Please note: **cisco_package** is <u>not</u> intended for use with 3rd Party RPMs, which target the `bash-shell` or `guestshell` 3rd Party environments. Please use Chef's **yum_package** provider for those environments.</i>

## <a name="Syntax">Syntax</a>

```
cisco_package 'name' do
  action                String
  source                String
}
```
where:

* `cisco_package` tells the chef-client to manage a package

* `name` is the name of the package

* `action` Optional. Valid settings are `:install` or `:remove`. Default is `:install`

* `source` Optional. Path to local file or URI for remote RPMs.

## <a name="examples">Examples</a>

* **Cisco RPMs**

```
cisco_package { 'n9000_sample':
  source  "http://myrepo.my_company.com/n9000_sample-1.0.0-7.0.3.x86_64.rpm",
}
```
```
cisco_package { 'n9000_sample':
  action  :remove
}
```
```
# Local RPM file
cisco_package { 'n9000_sample':
  source  '/bootflash/n9000_sample-1.0.0-7.0.3.x86_64.rpm',
  action  :install
}
```

## <a name="references">References</a>

[Chef package resources](https://docs.chef.io/resource_package.html) - Generic and specific package management resources

[Cisco Nexus Chef Modules](../README.md) - Resources, Providers, Utilities

[Cisco Nexus Programmability Guide](http://www.cisco.com/c/en/us/td/docs/switches/datacenter/nexus9000/sw/6-x/programmability/guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide/b_Cisco_Nexus_9000_Series_NX-OS_Programmability_Guide_chapter_01010.html) - Guestshell Documentation


