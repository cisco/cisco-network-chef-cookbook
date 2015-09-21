# CiscoSnmpUser resource for Chef.
#
# February 2015, Alex Hunsberger
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

require 'chef/provider'
require 'chef/resource'

class Chef
  class Resource
    class Resource::CiscoSnmpUser < Resource
      attr_accessor :user, :engine_id

      @@auth_choices = ['md5', 'sha', 'none']
      @@priv_choices = ['des', 'aes128', 'none']
      @@title_pattern = /^(\w+)\s*([0-9]{1,3}(?::[0-9]{1,3}){4,31})?\s*$/
      def initialize(name, run_context = nil)
        super
        @resource_name = :cisco_snmp_user
        @action = :create
        @allowed_actions = [:create, :destroy]
        @provider = Chef::Provider::CiscoSnmpUser
        validate_name(name.strip)
        @name = name.strip
        @user = @@title_pattern.match(@name)[1]
        @engine_id = @@title_pattern.match(@name)[2].nil? ? '' : @@title_pattern.match(@name)[2]
      end

      # use chef's built-in validation to validate name parameter
      def validate_name(arg = nil)
        set_or_return(:name, arg, :kind_of => String, :callbacks => {
                        'user must be string of word characters and Engine ID should be either empty string or 5 to 32 octets separated by colons' => lambda {
                          |name| !@@title_pattern.match(name).nil?
                        }
                      })
      end

      def auth_protocol(arg = nil)
        set_or_return(:auth_protocol, arg, :kind_of => String, :callbacks => {
                        "must be one of: [#{@@auth_choices.join(' ')}]" => lambda {
                          |proto| @@auth_choices.include? proto
                        }
                      })
      end

      def auth_password(arg = nil)
        set_or_return(:auth_password, arg, :kind_of => String)
      end

      def priv_protocol(arg = nil)
        set_or_return(:priv_protocol, arg, :kind_of => String, :callbacks => {
                        "must be one of: [#{@@priv_choices.join(' ')}]" => lambda {
                          |proto| @@priv_choices.include? proto
                        }
                      })
      end

      def priv_password(arg = nil)
        set_or_return(:priv_password, arg, :kind_of => String)
      end

      def groups(arg = nil)
        set_or_return(:groups, arg, :kind_of => Array, :callbacks => {
                        'must be kind of String' => lambda {
                          |groups| groups.select { |group| not group.kind_of? String }.empty?
                        }
                      })
      end

      def localized_key(arg = nil)
        set_or_return(:localized_key, arg, :kind_of => [TrueClass, FalseClass])
      end
    end
  end
end
