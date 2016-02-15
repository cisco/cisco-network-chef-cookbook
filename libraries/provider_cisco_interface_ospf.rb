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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    # Chef Provider definition for CiscoInterfaceOspf
    class CiscoInterfaceOspf < Chef::Provider
      provides :cisco_interface_ospf

      @interface_ospf = nil

      def initialize(new_resource, run_context)
        super(new_resource, run_context)

        fail 'interface name cannot be empty' if new_resource.name.empty?

        new_resource.name.downcase!
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        # will be nil if this instance doesn't exist yet
        @interface_ospf = Cisco::InterfaceOspf.interfaces[@new_resource.name]
      end

      def action_create
        # ospf and area are required for create action
        fail "[#{@new_resource.name}] Required property 'ospf' is missing" if
          new_resource.ospf.nil?
        fail "[#{@new_resource.name}] Required property 'area' is missing" if
          new_resource.area.nil?

        # remove old OSPF config if changed process or area
        if @interface_ospf &&
           (@interface_ospf.area != @new_resource.area.to_s ||
            @interface_ospf.ospf_name != @new_resource.ospf)
          converge_by('OSPF process name and/or area has changed ' \
                      "(#{@interface_ospf.ospf_name}, #{@interface_ospf.area}) " \
                      "=> (#{@new_resource.ospf}, #{@new_resource.area}), " \
                      'remove old config') do
            @interface_ospf.destroy
            @interface_ospf = nil
          end
        end

        # configure ospf on this interface if it isn't
        if @interface_ospf.nil?
          converge_by("configure ospf #{@new_resource.ospf} " \
                      "area #{@new_resource.area} " \
                      "on interface #{@new_resource.name}") {}
          return if whyrun_mode?
          @interface_ospf = Cisco::InterfaceOspf.new(@new_resource.name,
                                                     @new_resource.ospf,
                                                     @new_resource.area.to_s)
        end

        @new_resource.message_digest(@interface_ospf.default_message_digest) if
          @new_resource.message_digest.nil?

        unless @new_resource.message_digest == @interface_ospf.message_digest
          converge_by('config authentication message_digest to ' +
                      @new_resource.message_digest.to_s) do
            @interface_ospf.message_digest = @new_resource.message_digest
          end
        end

        if @new_resource.message_digest_key_id.nil? &&
           @new_resource.message_digest_algorithm_type.nil? &&
           @new_resource.message_digest_encryption_type.nil? &&
           @new_resource.message_digest_password.nil?
          # checking for nil password is sufficient to check if message_digest
          # is configured
          unless @interface_ospf.message_digest_password.nil?
            converge_by 'unconfigure message_digest' do
              @interface_ospf.message_digest_key_set(
                @interface_ospf.default_message_digest_key_id, '', '', '')
            end
          end
        else
          fail 'must supply message_digest_password' if
            @new_resource.message_digest_password.nil?
          fail 'must supply message_digest_key_id' if
            @new_resource.message_digest_key_id.nil?

          # supply defaults
          @new_resource.message_digest_algorithm_type(
            @interface_ospf.default_message_digest_algorithm_type.to_s) if
              @new_resource.message_digest_algorithm_type.nil?
          @new_resource.message_digest_encryption_type(
            @interface_ospf.default_message_digest_encryption_type.to_s) if
              @new_resource.message_digest_encryption_type.nil?

          # if any properties differ, reconfigure message_digest attrs
          # (not idempotent for cleartext passwords)
          unless @new_resource.message_digest_key_id ==
                 @interface_ospf.message_digest_key_id &&
                 @new_resource.message_digest_algorithm_type ==
                 @interface_ospf.message_digest_algorithm_type &&
                 @new_resource.message_digest_encryption_type ==
                 @interface_ospf.message_digest_encryption_type &&
                 @new_resource.message_digest_password ==
                 @interface_ospf.message_digest_password

            converge_by('configure message_digest ' \
                        "#{@new_resource.message_digest_key_id} " \
                        "#{@new_resource.message_digest_algorithm_type} " \
                        "#{@new_resource.message_digest_encryption_type} " \
                        "#{@new_resource.message_digest_password} ") do
              @interface_ospf.message_digest_key_set(
                @new_resource.message_digest_key_id,
                @new_resource.message_digest_algorithm_type,
                @new_resource.message_digest_encryption_type,
                @new_resource.message_digest_password)
            end
          end # end unless
        end

        # supply defaults
        @new_resource.cost(@interface_ospf.default_cost) if
          @new_resource.cost.nil?
        @new_resource.hello_interval(@interface_ospf.default_hello_interval) if
          @new_resource.hello_interval.nil?
        @new_resource.dead_interval(@interface_ospf.default_dead_interval) if
          @new_resource.dead_interval.nil?
        @new_resource.passive_interface(
          @interface_ospf.default_passive_interface) if
            @new_resource.passive_interface.nil?

        if @new_resource.cost != @interface_ospf.cost
          converge_by("update cost #{@interface_ospf.cost} => " +
                      @new_resource.cost.to_s) do
            @interface_ospf.cost = @new_resource.cost
          end
        end
        if @new_resource.hello_interval != @interface_ospf.hello_interval
          converge_by('update hello_interval ' \
                      "#{@interface_ospf.hello_interval} => " +
                      @new_resource.hello_interval.to_s) do
            @interface_ospf.hello_interval = @new_resource.hello_interval
          end
        end
        if @new_resource.dead_interval != @interface_ospf.dead_interval
          converge_by('update dead_interval ' \
                      "#{@interface_ospf.dead_interval} => " +
                      @new_resource.dead_interval.to_s) do
            @interface_ospf.dead_interval = @new_resource.dead_interval
          end
        end
        # rubocop:disable Style/GuardClause
        if @new_resource.passive_interface != @interface_ospf.passive_interface
          converge_by('update passive_interface ' \
                      "#{@interface_ospf.passive_interface} => " +
                      @new_resource.passive_interface.to_s) do
            @interface_ospf.passive_interface = @new_resource.passive_interface
          end
        end
        # rubocop:enable Style/GuardClause
      end # end action_create

      def action_destroy
        return if @interface_ospf.nil?
        converge_by "remove ospf configuration for #{@new_resource.name}" do
          @interface_ospf.destroy
          @interface_ospf = nil
        end
      end
    end
  end
end
