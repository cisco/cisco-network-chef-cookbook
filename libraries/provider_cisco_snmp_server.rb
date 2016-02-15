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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    # Chef Provider definition for CiscoSnmpServer
    class CiscoSnmpServer < Chef::Provider
      provides :cisco_snmp_server

      def whyrun_supported?
        true
      end

      def load_current_resource
        @element = Cisco::SnmpServer.new
      end

      def action_update
        @new_resource.contact(@element.default_contact) if
          @new_resource.contact.nil?
        if @element.contact != @new_resource.contact
          converge_by("update contact '#{@element.contact}'" \
                      " => '#{@new_resource.contact}'") do
            @element.contact = @new_resource.contact
          end
        end

        @new_resource.location(@element.default_location) if
          @new_resource.location.nil?
        if @element.location != @new_resource.location
          converge_by("update location '#{@element.location}'" \
                      " => '#{@new_resource.location}'") do
            @element.location = @new_resource.location
          end
        end

        @new_resource.aaa_user_cache_timeout(@element.default_aaa_user_cache_timeout) if
          @new_resource.aaa_user_cache_timeout.nil?
        if @element.aaa_user_cache_timeout != @new_resource.aaa_user_cache_timeout
          converge_by('update aaa_user_cache_timeout ' \
                      "'#{@element.aaa_user_cache_timeout}'" \
                      " => '#{@new_resource.aaa_user_cache_timeout}'") do
            @element.aaa_user_cache_timeout = @new_resource.aaa_user_cache_timeout
          end
        end

        @new_resource.packet_size(@element.default_packet_size) if
          @new_resource.packet_size.nil?
        if @element.packet_size != @new_resource.packet_size
          converge_by("update packet_size '#{@element.packet_size}'" \
                      " => '#{@new_resource.packet_size}'") do
            @element.packet_size = @new_resource.packet_size
          end
        end

        @new_resource.global_enforce_priv(@element.default_global_enforce_priv) if
          @new_resource.global_enforce_priv.nil?
        if @element.global_enforce_priv? != @new_resource.global_enforce_priv
          converge_by("update global_enforce_priv '#{@element.global_enforce_priv?}" \
                      " => '#{@new_resource.global_enforce_priv}'") do
            @element.global_enforce_priv = @new_resource.global_enforce_priv
          end
        end

        @new_resource.protocol(@element.default_protocol) if
          @new_resource.protocol.nil?
        if @element.protocol? != @new_resource.protocol
          converge_by("update protocol '#{@element.protocol?}'" \
                      " => '#{@new_resource.protocol}'") do
            @element.protocol = @new_resource.protocol
          end
        end

        @new_resource.tcp_session_auth(@element.default_tcp_session_auth) if
          @new_resource.tcp_session_auth.nil?
        # rubocop:disable Style/GuardClause
        if @element.tcp_session_auth? != @new_resource.tcp_session_auth
          converge_by("update tcp_session_auth '#{@element.tcp_session_auth?}'" \
                      " => '#{@new_resource.tcp_session_auth}'") do
            @element.tcp_session_auth = @new_resource.tcp_session_auth
          end
        end
        # rubocop:enable Style/GuardClause
      end
    end
  end
end
