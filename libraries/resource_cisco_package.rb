# February 2015, Chris Van Heuveln
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

class Chef
  class Resource
    # CiscoPackage is essentially just a wrapper for yum to facilitate package
    # handling from Nexus Guestshell that is targeted for the host:
    #
    #  o Nexus Native bash shell:
    #     If chef-client runs from here then standard yum methods are invoked
    #     directly to handle the package operations. The preference is to use
    #     either "package" or "yum_package" for this environment.
    #
    #  o Nexus Guestshell:
    #     If chef-client runs from here then package operations are handled via
    #     Nexus NXAPI and target the host environment rather than the Guestshell
    #     itself. Use either "package" or "yum_package" for local package
    #     handling within Guestshell.
    class CiscoPackage < Chef::Resource::Package::YumPackage
      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_package
      end
    end
  end
end
