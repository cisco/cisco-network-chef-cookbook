# March 2015, Alex Hunsberger
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
    # CiscoTacacsServerHost resource for Chef.
    class CiscoTacacsServerHost < Chef::Resource
      attr_accessor :cisco_tacacs_server_host

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_tacacs_server_host
        @action = :create
        @allowed_actions = [:create, :destroy]
        @provider = Chef::Provider::CiscoTacacsServerHost
      end

      def port(arg=nil)
        set_or_return(:port, arg, kind_of: Fixnum)
      end

      def encryption_type(arg=nil)
        set_or_return(:encryption_type, arg,
                      equal_to: %w(none clear encrypted default))
      end

      def encryption_password(arg=nil)
        set_or_return(:encryption_password, arg, kind_of: String)
      end

      def timeout(arg=nil)
        set_or_return(:timeout, arg, kind_of: Fixnum)
      end
    end
  end
end
