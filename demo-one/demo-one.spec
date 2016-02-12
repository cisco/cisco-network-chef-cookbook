#
# demo-one.spec
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
# This spec file was inspired by content from:
#   http://stackoverflow.com/questions/880227/what-is-the-minimum-i-have-to-do-to-create-an-rpm-file
#
# Don't try fancy stuff like debuginfo, which is useless on binary-only
# packages. Don't strip binary too
# Be sure buildpolicy set to do nothing
%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Summary: A simple rpm package for demo purposes
Name: demo-one
Version: 1.0
Release: 1
License: GPL+
Group: Development/Tools
SOURCE0 : %{name}-%{version}.tar.gz
#URL: http://demo-one.company.com/

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

%description
%{summary}

%prep
%setup -q

%build
# Empty section.

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
cp -a * %{buildroot}

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
/etc/demo-one
%config(noreplace) /etc/demo-one/demo-one.conf 
%{_bindir}/*

%changelog
* Mon Mar 2 2015  Chris Van Heuveln <cvanheuv@cisco.com> 1.0-1
- First Build

