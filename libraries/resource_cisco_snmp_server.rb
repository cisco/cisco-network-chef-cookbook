# December 2014, Alex Hunsberger
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
    # Chef Provider definition for CiscoSnmpServer
    class CiscoSnmpServer < Chef::Resource
      attr_accessor :cisco_snmp_server

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_snmp_server
        @action = :update
        @allowed_actions = [:update]
      end

      def aaa_user_cache_timeout(arg=nil)
        set_or_return(:aaa_user_cache_timeout, arg, kind_of: Fixnum)
      end

      def location(arg=nil)
        set_or_return(:location, arg, kind_of: String)
      end

      def contact(arg=nil)
        set_or_return(:contact, arg, kind_of: String)
      end

      def packet_size(arg=nil)
        set_or_return(:packet_size, arg, kind_of: Fixnum)
      end

      def global_enforce_priv(arg=nil)
        set_or_return(:global_enforce_priv, arg, kind_of: [TrueClass, FalseClass])
      end

      def protocol(arg=nil)
        set_or_return(:protocol, arg, kind_of: [TrueClass, FalseClass])
      end

      def tcp_session_auth(arg=nil)
        set_or_return(:tcp_session_auth, arg, kind_of: [TrueClass, FalseClass])
      end
    end
  end
end
