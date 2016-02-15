# February 2015, Alex Hunsberger
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

require 'chef/provider'
require 'chef/resource'

class Chef
  class Resource
    # CiscoSnmpUser resource for Chef.
    class CiscoSnmpUser < Chef::Resource
      attr_accessor :user, :engine_id

      # rubocop:disable Style/ClassVars
      @@title_pattern = /^(\w+)\s*([0-9]{1,3}(?::[0-9]{1,3}){4,31})?\s*$/
      # rubocop:enable Style/ClassVars

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_snmp_user
        @action = :create
        @allowed_actions = [:create, :destroy]
        @provider = Chef::Provider::CiscoSnmpUser
        validate_name(name.strip)
        @name = name.strip
        m = @@title_pattern.match(@name)
        @user = m[1]
        @engine_id = m[2].nil? ? '' : m[2]
      end

      # use chef's built-in validation to validate name parameter
      def validate_name(arg=nil)
        set_or_return(:name, arg, kind_of: String, callbacks: {
                        'user must be string of word characters and ' \
                        'Engine ID should be either empty string or ' \
                        '5 to 32 octets separated by colons' => lambda do |name|
                          !@@title_pattern.match(name).nil?
                        end,
                      })
      end

      def auth_protocol(arg=nil)
        set_or_return(:auth_protocol, arg,
                      kind_of:  String,
                      equal_to: %w(md5 sha none))
      end

      def auth_password(arg=nil)
        set_or_return(:auth_password, arg, kind_of: String)
      end

      def priv_protocol(arg=nil)
        set_or_return(:priv_protocol, arg,
                      kind_of:  String,
                      equal_to: %w(des aes128 none))
      end

      def priv_password(arg=nil)
        set_or_return(:priv_password, arg, kind_of: String)
      end

      def groups(arg=nil)
        set_or_return(:groups, arg, kind_of: Array, callbacks: {
                        'must be kind of String' => lambda do |groups|
                          groups.select { |group| !group.kind_of? String }.empty?
                        end,
                      })
      end

      def localized_key(arg=nil)
        set_or_return(:localized_key, arg, kind_of: [TrueClass, FalseClass])
      end
    end
  end
end
