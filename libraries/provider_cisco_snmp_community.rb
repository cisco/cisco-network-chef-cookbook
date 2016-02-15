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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    # Chef Provider definition for CiscoSnmpCommunity
    class CiscoSnmpCommunity < Chef::Provider
      provides :cisco_snmp_community

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @snmp_community = nil
        @name = new_resource.name
        Chef::Log.debug "Cisco snmpcommunity #{@name}"
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        @snmp_community = Cisco::SnmpCommunity.communities[@name]
      end

      def new_group
        if @new_resource.group.nil?
          Cisco::SnmpCommunity.default_group
        else
          @new_resource.group
        end
      end

      def action_create
        if @snmp_community.nil?
          instantiate = whyrun_mode? ? false : true
          @snmp_community = Cisco::SnmpCommunity.new(@name, new_group, instantiate)
        end
        @new_resource.group(@snmp_community.default_group) if
          @new_resource.group.nil?
        if @snmp_community.group != new_group
          converge_by("create SnmpCommunity '#{@name}', group '#{new_group}'") do
            @snmp_community.group = new_group
          end
        end

        @new_resource.acl(@snmp_community.default_acl) if @new_resource.acl.nil?
        # rubocop:disable Style/GuardClause
        if @new_resource.acl != @snmp_community.acl
          converge_by('update SnmpCommunity ACL ' \
                      "'#{@snmp_community.acl}' => '#{@new_resource.acl}'") do
            @snmp_community.acl = @new_resource.acl
          end
        end
        # rubocop:enable Style/GuardClause
      end

      def action_destroy
        return if @snmp_community.nil?
        converge_by("destroy SnmpCommunity '#{@name}'") do
          @snmp_community.destroy
        end
      end
    end
  end
end
