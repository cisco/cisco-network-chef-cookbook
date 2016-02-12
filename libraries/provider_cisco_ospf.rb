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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    # CiscoOspf provider for Chef.
    class CiscoOspf < Chef::Provider
      provides :cisco_ospf

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        Chef::Log.debug "Load current resource for router ospf #{@new_resource.name}"
        @current_resource = Chef::Resource::CiscoOspf.new(@new_resource.name)
        ospfs = Cisco::RouterOspf.routers
        ospfs.each do |id, ospf|
          next unless id == @new_resource.name
          @current_resource.exists = true
          @ospf = ospf
          return @ospf
        end
        @current_resource.exists = false
        @ospf = Cisco::RouterOspf.new(@new_resource.name, false)
      end

      def action_create
        if current_resource.exists
          Chef::Log.debug "router ospf #{@current_resource.name} already enabled"
        else
          converge_by("enable router ospf #{@ospf.name}") do
            @ospf.create
          end
        end
      end

      def action_destroy
        if current_resource.exists
          converge_by("remove router ospf #{@ospf.name}") do
            @ospf.destroy
          end
        else
          Chef::Log.debug "router ospf #{@new_resource.name} already removed"
        end
      end
    end # class CiscoOspf
  end # class Provider
end # class Chef
