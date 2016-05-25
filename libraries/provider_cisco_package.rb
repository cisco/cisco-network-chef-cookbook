# February 2015, Chris Van Heuveln, Alex Hunsberger
#
# Copyright (c) 2015-2016 Cisco and/or its affiliates.
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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    class Package
      # CiscoPackage is essentially just a wrapper for yum to facilitate package
      # handling from Nexus Guestshell that is targeted for the host:
      #
      #  o Nexus Native bash shell:
      #     If chef-client runs from here then standard yum methods are invoked
      #     directly to handle the package operations. The preference is to use
      #     either "package" or "yum_package" for this environment.
      #
      #  o Nexus Guestshell:
      #     If chef-client runs from here then package operations are handled
      #     via Nexus NXAPI and target the host environment rather than the
      #     Guestshell itself. Use either "package" or "yum_package" for local
      #     package handling within Guestshell.
      class CiscoPackage < Chef::Provider::Package::Yum
        provides :cisco_package, os: 'linux'

        def whyrun_supported?
          true
        end

        def detect_gs
          node['platform'][/centos/]
          true # temporarily force use of nxapi yum cli in native
        end

        def decompose_metadata(pkg)
          puts "\nCalling decompose_metadata"
          # Sample output from 'rpm -qip' command
          #
          # Name        : nxos.sample-n9k_EOR
          # Version     : 1.0.0
          # Release     : 7.0.3.I4.1
          # Architecture: lib32_n9000
          # Install Date: (not installed)
          # Group       : Patch-RPM/swid-inseor-system/restart/none
          # Size        : 452807
          # License     : Cisco proprietary
          # Signature   : (none)
          # Source RPM  : nxos.sample-n9k_EOR-1.0.0-7.0.3.I4.1.src.rpm
          # Build Date  : Mon May 23 18:18:44 2016
          # Build Host  : rtp-ads-432
          # Relocations : (not relocatable)
          # Packager    : Wind River <info@windriver.com>
          # URL         : http://cisco.com/
          # Summary     : This is patch for sample-n9k_EOR
          # Description :
          # This is a patch for sample-n9k_EOR.The build type is final.

          # Assume package is on bootflash if path not provided.
          pkg = pkg[/bootflash/] ? pkg : "/bootflash/#{pkg}"
          rpm_data = `rpm -qip #{pkg}` 
          n_re = /Name(?:\s+ )?:\s+(\S+)/
          v_re = /Version(?:\s+ )?:\s+(\S+)/
          r_re = /Release(?:\s+ )?:\s+(\S+)/
          a_re = /Architecture(?:\s+ )?:\s+(\S+)/
          name = n_re.match(rpm_data) ? Regexp.last_match(1) : nil
          ver  = v_re.match(rpm_data) ? Regexp.last_match(1) : nil
          rel  = r_re.match(rpm_data) ? Regexp.last_match(1) : nil
          arch = a_re.match(rpm_data) ? Regexp.last_match(1) : nil
          
          fail "Unable to parse rpm data from #{pkg}\n#{rpm_data}" if
            [name, ver, rel, arch].include?(nil)

          @pkg_nm = name
          @ver = "#{ver}-#{rel}"
          @arch_nm = arch   
        end

        def decompose_filename
          puts "\nCalling decompose_filename"
          # RPM filename patterns.
          # 1) chef-12.0.0alpha.2+20150319.git.1.b6f-1.el5.x86_64.rpm
          @name_ver_arch_regex = /^([\w\-\+]+)-(\d+\..*)\.(\w{4,})(?:\.rpm)?$/ 
          # 2) n9000-dk9.LIBPROCMIBREST-1.0.0-7.0.3.x86_64.rpm
          @name_ver_arch_regex_nxos = /^(.*)-([\d\.]+-[\d\.]+)\.(\w{4,})\.rpm$/
          # 3) b+z-ip2.x64_64
          @name_arch_regex = /^([\w\-\+]+)\.(\w+)$/

          if @new_resource.package_name =~ @name_ver_arch_regex ||
             @new_resource.package_name =~ @name_ver_arch_regex_nxos
            @pkg_nm = Regexp.last_match(1)
            @ver = Regexp.last_match(2)
            @arch_nm = Regexp.last_match(3)
          # next, second most complex (name.arch)
          elsif @new_resource.package_name =~ @name_arch_regex
            @pkg_nm = Regexp.last_match(1)
            @arch_nm = Regexp.last_match(2)
          # otherwise must be shortname
          else
            @pkg_nm = @new_resource.package_name
          end
          # try to set version via new_resource.version if it wasn't parsed
          @ver ||= @new_resource.version
        end

        def load_current_resource
          if detect_gs
            Chef::Log.debug 'load_current_resource (GS, use nxapi yum)'

            # package name can be either:
            # 1. shortname, e.g. bgp-dev
            # 2. name.arch, e.g. bgp-dev.x86_64
            # 3. filename, e.g. bgp-dev.1.2.3.x86_64.rpm
            # 4. ios-path, e.g. bootflash:/home/bgp-dev.1.2.3.x86_64.rpm
            # 5. unix-path, e.g. /bootflash/home/bgp-dev.1.2.3.x86_64.rpm

            # Decompose the name, version and architecture 
            if @new_resource.source
              decompose_metadata(@new_resource.source)
            elsif @new_resource.package_name[/\.rpm/]
              decompose_metadata(@new_resource.package_name)
            else
              decompose_filename
            end

            # replace /bootflash/path with bootflash:path
            @new_resource.source.gsub!(%r{^/([^/]+)/}, '\1:') if
              @new_resource.source
          else
            Chef::Log.debug 'load_current_resource (NATIVE, use native yum)'

            # replace bootflash:path with /bootflash/path for native env
            @new_resource.source.gsub!(%r{^([^/]+):/?}, '/\1/') if
              @new_resource.source
            super
          end
        end

        def action_install
          if detect_gs
            Chef::Log.debug 'action_install (GS, use nxapi yum)'

            inst_ver = installed_ver
            # want to install the package if:
            # 1. there is no version installed
            # 2. the recipe specifies a version different than installed ver
            if (!inst_ver) || (@ver && @ver != inst_ver)
              converge_by "install package #{@new_resource.package_name}" do
                if @new_resource.source
                  Cisco::Yum.install(@new_resource.source)
                else
                  Cisco::Yum.install(@new_resource.package_name)
                end
              end
            end
          else
            Chef::Log.debug 'action_install (NATIVE, use native yum)'
            super
          end
        end

        def action_remove
          if detect_gs
            Chef::Log.debug 'action_remove (GS, use nxapi yum)'

            inst_ver = installed_ver
            # want to remove if:
            # 1. package is installed and matches recipe version
            # 2. package is installed and no recipe version specified
            if inst_ver && (@ver == inst_ver || !@ver)
              converge_by "remove package #{@new_resource.package_name}" do
                if @arch_nm
                  Cisco::Yum.remove("#{@pkg_nm}.#{@arch_nm}")
                else
                  Cisco::Yum.remove(@pkg_nm)
                end
              end
            end
          else
            Chef::Log.debug 'action_remove (NATIVE, use native yum)'
            super
          end
        end

        # this method in package.rb checks the environment for installable
        # candidates. we don't want to do this if we're using nxapi yum
        def define_resource_requirements
          super unless detect_gs
        end

        def installed_ver
          if @arch_nm
            installed_ver = Cisco::Yum.query("#{@pkg_nm}.#{@arch_nm}")
          else
            installed_ver = Cisco::Yum.query(@pkg_nm)
          end
          installed_ver
        end
      end # class CiscoPackage
    end # class Package
  end # class Provider
end # class Chef
