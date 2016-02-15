# Author: Alex Hunsberger
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
    # CiscoInterface provider usage:
    #
    # The user can choose to either set layer 2 properties (switchport vtp, etc)
    # or layer 3 properties (ip address, etc). Which properties are
    # configured is determined by the switchport_mode specified in the
    # recipe, or the default switchport_mode if default or unspecified.
    #
    # Virtual interfaces can be created and destroyed, but physical interfaces
    # technically cannot. The default action (create) will set properties for
    # an interface. Destorying a virtual interface will unconfigure it.
    class CiscoInterface < Chef::Provider
      provides :cisco_interface

      def initialize(new_resource, run_context)
        super(new_resource, run_context)

        fail 'Interface name cannot be empty' if new_resource.name.empty?

        @interface = nil
        @name = new_resource.name
        Chef::Log.debug "Cisco interface #{@name}"
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        # will return nil if no interface with this name exists
        @interface = Cisco::Interface.interfaces[@name]
      end

      def prop_set(props)
        Cisco::ChefUtils.generic_prop_set(self, '@interface', props)
      end

      # Wrapper for properties that are only supported on certain interfaces;
      # e.g. svi props are only valid on Vlan interfaces. Skip a property unless
      # node_utils layer returns non-nil or it's an explicit property in the recipe.
      def prop_set_if_supported(props)
        props.each do |prop|
          prop_set([prop]) if @interface.send(prop) || @new_resource.send(prop)
        end
      end

      def action_create
        converge_by("create interface '#{@name}'") {} if @interface.nil?
        instantiate = whyrun_mode? ? false : true
        @interface = Cisco::Interface.new(@name, instantiate) if @interface.nil?

        # conditions in which we want to set ipv4 properties
        if @new_resource.switchport_mode == 'disabled' ||
           ((@interface.default_switchport_mode == :disabled) &&
            (@new_resource.switchport_mode.nil? ||
             (@new_resource.switchport_mode == 'default')))

          set_layer3_properties
        else # switchport will be enabled
          set_layer2_properties
        end
      end # action_create

      def set_switchport_mode
        # switchport must be enabled or disabled before other properties can be
        # configured.
        @new_resource.switchport_mode(@interface.default_switchport_mode.to_s) if
          @new_resource.switchport_mode.nil? ||
          @new_resource.switchport_mode == 'default'

        return unless @interface.switchport_mode.to_s != @new_resource.switchport_mode
        converge_by("update switchport_mode #{@interface.switchport_mode} => " +
                    @new_resource.switchport_mode) do
          @interface.switchport_mode = @new_resource.switchport_mode.to_sym
        end
      end

      def set_common_properties
        prop_set([:description, :encapsulation_dot1q, :mtu, :shutdown, :negotiate_auto])
      end

      def set_layer3_properties
        # Disable switchport
        set_switchport_mode
        set_common_properties
        # set vrf before other L3 props to avoid them being wiped out
        prop_set([:vrf, :ipv4_proxy_arp, :ipv4_redirects])
        prop_set_if_supported([:svi_autostate, :svi_management])
        set_layer3_combo_properties
      end

      def set_layer3_combo_properties
        # ipv4 addr/mask
        @new_resource.ipv4_address(@interface.default_ipv4_address) if
          @new_resource.ipv4_address.nil?
        @new_resource.ipv4_netmask_length(@interface.default_ipv4_netmask_length) if
          @new_resource.ipv4_netmask_length.nil?

        return unless @interface.ipv4_address != @new_resource.ipv4_address ||
                      @interface.ipv4_netmask_length != @new_resource.ipv4_netmask_length
        converge_by("update ipv4_address/netmask '#{@interface.ipv4_address}/" \
                    "#{@interface.ipv4_netmask_length}' => #{@new_resource.ipv4_address}/" +
                    @new_resource.ipv4_netmask_length.to_s) do
          @interface.ipv4_addr_mask_set(@new_resource.ipv4_address,
                                        @new_resource.ipv4_netmask_length)
        end
      end

      def set_layer2_properties
        # Disable switchport
        set_switchport_mode
        @new_resource.switchport_trunk_allowed_vlan.gsub!(/, */, ',') unless
          @new_resource.switchport_trunk_allowed_vlan.nil?
        prop_set([:access_vlan, :switchport_autostate_exclude,
                  :switchport_trunk_allowed_vlan, :switchport_trunk_native_vlan,
                  :switchport_vtp
                 ])
      end

      def action_destroy
        return if @interface.nil?
        converge_by("destroy interface #{@name}") do
          @interface.destroy
          @interface = nil
        end
      end
    end
  end
end
