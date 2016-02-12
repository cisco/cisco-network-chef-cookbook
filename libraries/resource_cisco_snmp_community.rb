# February 2015, Glenn F. Matthews
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
    # Chef Resource definition for CiscoSnmpCommunity
    class CiscoSnmpCommunity < Chef::Resource
      attr_accessor :exists

      def initialize(community, run_context=nil)
        super
        @resource_name = :cisco_snmp_community
        @action = :create
        @allowed_actions = [:create, :destroy]
      end

      def community(arg=nil)
        set_or_return(:community, arg, kind_of: String)
      end

      def group(arg=nil)
        set_or_return(:group, arg, kind_of: String)
      end

      def acl(arg=nil)
        set_or_return(:acl, arg, kind_of: String)
      end
    end
  end
end
