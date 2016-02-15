# December 2014, Mike Wiebe
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
    # CiscoTacacsServer resource for Chef.
    class CiscoTacacsServer < Chef::Resource
      attr_accessor :exists, :cisco_tacacs_server

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_tacacs_server
        @action = :update
        @allowed_actions = [:update, :create, :destroy]
      end

      def timeout(arg=nil)
        set_or_return(:timeout, arg, kind_of: Fixnum)
      end

      def deadtime(arg=nil)
        set_or_return(:deadtime, arg, kind_of: Fixnum)
      end

      def directed_request(arg=nil)
        set_or_return(:directed_request, arg, equal_to: [true, false])
      end

      def source_interface(arg=nil)
        set_or_return(:source_interface, arg, kind_of: String)
      end

      def encryption_type(arg=nil)
        set_or_return(:encryption_type, arg, equal_to: %w(default clear encrypted none))
      end

      def encryption_password(arg=nil)
        set_or_return(:encryption_password, arg, kind_of: String)
      end
    end
  end
end
