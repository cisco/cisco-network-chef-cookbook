# December 2014, Jie Yang
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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    # Chef Provider definition for CiscoVlan
    class CiscoVlan < Chef::Provider
      provides :cisco_vlan

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @vlan = nil
        @name = new_resource.name
        Chef::Log.debug "Cisco vlan #{@name}"
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        Chef::Log.debug "Load current resource for vlan #{@name}"
        @vlan = Cisco::Vlan.vlans[@name]
      end

      def action_create
        converge_by("Create vlan '#{@name}'") {} if @vlan.nil?
        instantiate = whyrun_mode? ? false : true
        @vlan = Cisco::Vlan.new(@name, instantiate) if @vlan.nil?

        props = [:vlan_name, :state, :shutdown]
        Cisco::ChefUtils.generic_prop_set(self, '@vlan', props)
      end

      def action_destroy
        return if @vlan.nil?
        converge_by("destroy vlan #{@name}") do
          @vlan.destroy
          @vlan = nil
        end
      end
    end
  end
end
