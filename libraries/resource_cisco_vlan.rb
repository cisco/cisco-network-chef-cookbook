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

class Chef
  class Resource
    # Chef Resource definition for CiscoVlan
    class CiscoVlan < Chef::Resource
      attr_accessor :exists

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_vlan
        @action = :create
        @allowed_actions = [
          :create,
          :destroy,
        ]

        # The vlan id is the name of the Resource (@new_resource.name),
        # e.g.: cisco_vlan "200".
        # @vlan_name refers to the name keyword in vlan submode.
        @vlan_name = nil
        @state = nil
        @shutdown = nil
      end

      def vlan_name(arg=nil)
        set_or_return(:vlan_name, arg, kind_of: String)
      end

      def state(arg=nil)
        set_or_return(:state, arg, kind_of: String)
      end

      def shutdown(arg=nil)
        set_or_return(:shutdown, arg, kind_of: [TrueClass, FalseClass])
      end
    end
  end
end
