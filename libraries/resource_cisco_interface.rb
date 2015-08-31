#
# resource_cisco_interface.rb
#
# Author: Alex Hunsberger
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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
    class Resource::CiscoInterface < Resource
      attr_accessor :cisco_interface

      @@sw_mode_choices =
        ['disabled', 'access', 'tunnel', 'fex_fabric', 'trunk', 'default']

      def initialize(interface_name, run_context = nil)
        super
        @resource_name = :cisco_interface
        @action = :create
        @allowed_actions = [:create, :destroy]
        @name = interface_name.downcase
      end

      def access_vlan(arg = nil)
        set_or_return(:access_vlan, arg, :kind_of => Fixnum)
      end

      def description(arg = nil)
        set_or_return(:description, arg, :kind_of => String)
      end

      def shutdown(arg = nil)
        set_or_return(:shutdown, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def ipv4_proxy_arp(arg = nil)
        set_or_return(:ipv4_proxy_arp, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def ipv4_redirects(arg = nil)
        set_or_return(:ipv4_redirects, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def negotiate_auto(arg = nil)
        set_or_return(:negotiate_auto, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def switchport_autostate_exclude(arg = nil)
        set_or_return(:switchport_autostate_exclude, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def switchport_vtp(arg = nil)
        set_or_return(:switchport_vtp, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def svi_autostate(arg = nil)
        set_or_return(:svi_autostate, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def svi_management(arg = nil)
        set_or_return(:svi_management, arg,
                      :kind_of => [TrueClass, FalseClass])
      end

      def ipv4_address(arg = nil)
        set_or_return(:ipv4_address, arg, :kind_of => String, :callbacks => {
                        "must be a valid ipv4 address" => lambda {
                          |addr| addr == 'default' or IPAddress.valid_ipv4? addr
                        }
                      })
      end

      def ipv4_netmask_length(arg = nil)
        set_or_return(:ipv4_netmask_length, arg, :kind_of => Fixnum, :callbacks => {
                        "netmask length must be between 0 and 32" => lambda {
                          |mask| mask == 'default' or mask.between?(0, 32)
                        }
                      })
      end

      def switchport_mode(arg = nil)
        set_or_return(:switchport_mode, arg, :kind_of => String, :callbacks => {
                        "must be one of: [#{@@sw_mode_choices.join(' ')}]" => lambda {
                          |mode| @@sw_mode_choices.include? mode.downcase
                        }
                      })
      end

      def vrf(arg = nil)
        set_or_return(:vrf, arg, :kind_of => String)
      end
    end
  end
end
