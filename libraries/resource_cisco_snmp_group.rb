#
# Chef Resource definition for CiscoSnmpGroup
#
# February 2015, Jie Yang
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
    class Resource::CiscoSnmpGroup < Resource

      def initialize(group, run_context=nil)
        super
        @resource_name = :cisco_snmp_group
        @action = :create
        @allowed_actions = [:create, :destroy]
      end

      def group(arg=nil)
        set_or_return(:group, arg, :kind_of => String)
      end
    end
  end
end

