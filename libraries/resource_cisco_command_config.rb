# December 2014, Chris Van Heuveln
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

class Chef
  class Resource
    # CiscoCommandConfig resource for Chef.
    # This resource allows raw configurations to be managed by chef.
    # It serves as a stopgap until specialized resources are created.
    #
    # It has the following limitations:
    # * The input message buffer is limited to 500KB
    # * Order is important. Some dependent commands may fail if their associated
    #   `feature` configuration is not enabled first
    # * Indentation counts! It implies sub-mode configuration. Use the switch's
    #   running-config as a guide and do not indent configurations that are not
    #   normally indented. Do not use tabs to indent.
    # * Inline comments must be prefixed by ! or #
    # * Negating a submode will also remove configuratons under that submode,
    #   without having to specify every submode config statement:
    #   `no router ospf RED` removes all configuration under router ospf RED
    # * Syntax does not auto-complete: use `Ethernet1/1`, not `Eth1/1`
    # * If a CLI command is rejected during configuration, the resource will
    #   abort at that point and will not continue to issue any remaining CLI.
    #   For this reason it is recommended to limit the scope of each instance
    #   of this resource.
    class CiscoCommandConfig < Chef::Resource
      attr_accessor :exists, :cisco_command_config

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_command_config
        @action = :update
        @allowed_actions = [:update]
      end

      def command(arg=nil)
        set_or_return(:command, arg, kind_of: String)
      end
    end
  end   # class Resource
end     # class Chef
