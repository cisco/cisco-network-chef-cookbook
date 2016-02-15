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

require 'ipaddr'

class Chef
  class Resource
    # Chef Resource definition for CiscoInterfaceOspf
    class CiscoInterfaceOspf < Chef::Resource
      def initialize(interface_name, run_context=nil)
        super
        @resource_name = :cisco_interface_ospf
        @action = :create
        @allowed_actions = [:create, :destroy]
      end

      # required
      def ospf(arg=nil)
        set_or_return(:ospf, arg, kind_of: String)
      end

      # required
      def area(arg=nil)
        # Coerce numeric area to the expected dot-decimal format.
        arg = IPAddr.new(arg.to_i, Socket::AF_INET).to_s unless
          arg.nil? || arg.to_s.match(/\./)
        set_or_return(:area, arg, kind_of: String)
      end

      def message_digest(arg=nil)
        set_or_return(:message_digest, arg, equal_to: [true, false])
      end

      def message_digest_key_id(arg=nil)
        set_or_return(:message_digest_key_id, arg, kind_of: Fixnum)
      end

      def message_digest_algorithm_type(arg=nil)
        set_or_return(:message_digest_algorithm_type, arg,
                      kind_of:  String,
                      equal_to: %w(md5))
      end

      def message_digest_encryption_type(arg=nil)
        set_or_return(:message_digest_encryption_type, arg,
                      kind_of:  String,
                      equal_to: %w(cleartext 3des cisco_type_7))
      end

      def message_digest_password(arg=nil)
        set_or_return(:message_digest_password, arg, kind_of: String)
      end

      def cost(arg=nil)
        set_or_return(:cost, arg, kind_of: Fixnum)
      end

      def hello_interval(arg=nil)
        set_or_return(:hello_interval, arg, kind_of: Fixnum)
      end

      def dead_interval(arg=nil)
        set_or_return(:dead_interval, arg, kind_of: Fixnum)
      end

      def passive_interface(arg=nil)
        set_or_return(:passive_interface, arg, kind_of: [TrueClass, FalseClass])
      end
    end
  end
end
