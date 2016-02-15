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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider
    # CiscoSnmpUser provider for Chef.
    # Uniqueness about SnmpUser:
    # 1) All properties must be configured in a single config string
    # 2) Configuring an SnmpUser of the same name/group/etc won't update
    #    an existing SnmpUser in config, you must destroy/re-create to update
    # 3) There may be >1 users with the same name configured, make the
    #    simplifying assumption the user only intends to have a single snmp
    #    user per unique name
    # 4) auth/priv passwords cannot be retrieved directly because they're
    #    hashed, can only re-hash and compare
    class CiscoSnmpUser < Chef::Provider
      provides :cisco_snmp_user

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @user = nil
      end

      def load_current_resource
        @current_resource = Chef::Resource::CiscoSnmpUser.new(@new_resource.name)

        # rubocop:disable Style/BlockDelimiters
        @user = Cisco::SnmpUser.users.select { |_index, user|
          user.name == @new_resource.user && user.engine_id == @new_resource.engine_id
        }.values.first
        # rubocop:enable Style/BlockDelimiters

        return if @user.nil?
        @current_resource.groups(@user.groups)
        @current_resource.auth_protocol(@user.auth_protocol.to_s)
        @current_resource.priv_protocol(@user.priv_protocol.to_s)
        @current_resource.localized_key(false) if @current_resource.localized_key.nil?
      end

      def action_create
        set_defaults

        return unless @user.nil? || (!@user.nil? && properties_differ?)

        # must destroy and re-create to update
        @user.destroy unless @user.nil?

        # if this user doesn't exist yet, @curr_resource will just display nothing
        converge_by("user: #{@new_resource.user}, " +
                    (@new_resource.engine_id.empty? ? '' : "engine id: #{@new_resource.engine_id}, ") +
                    "update the following:\n" \
                    'groups ' \
                    "#{@current_resource.groups} => #{@new_resource.groups}\n" \
                    'auth_protocol ' \
                    "#{@current_resource.auth_protocol} => #{@new_resource.auth_protocol}\n" \
                    'auth_password ' \
                    "#{@current_resource.auth_password} => #{@new_resource.auth_password}\n" \
                    'priv_protocol ' \
                    "#{@current_resource.priv_protocol} => #{@new_resource.priv_protocol}\n" \
                    'priv_password ' \
                    "#{@current_resource.priv_password} => #{@new_resource.priv_password}\n" \
                    'localized_key ' \
                    "#{@current_resource.localized_key} => #{@new_resource.localized_key}\n") do
          # snmp user must be configured in a single command
          @user = Cisco::SnmpUser.new(@new_resource.user,
                                      @new_resource.groups,
                                      @new_resource.auth_protocol.to_sym,
                                      @new_resource.auth_password,
                                      @new_resource.priv_protocol.to_sym,
                                      @new_resource.priv_password,
                                      @new_resource.localized_key,
                                      @new_resource.engine_id)
        end # converge
      end

      def set_defaults
        # don't select a default auth/priv protocol if the user hasn't
        # supplied an auth/priv password
        if (!@new_resource.auth_password.nil?) && @new_resource.auth_protocol.nil?
          @new_resource.auth_protocol(Cisco::SnmpUser.default_auth_protocol.to_s)
        elsif @new_resource.auth_protocol.nil?
          @new_resource.auth_protocol('none')
        end
        if (!@new_resource.priv_password.nil?) && @new_resource.priv_protocol.nil?
          @new_resource.priv_protocol(Cisco::SnmpUser.default_priv_protocol.to_s)
        elsif @new_resource.priv_protocol.nil?
          @new_resource.priv_protocol('none')
        end

        @new_resource.auth_password(Cisco::SnmpUser.default_auth_password) if
          @new_resource.auth_password.nil?
        @new_resource.priv_password(Cisco::SnmpUser.default_priv_password) if
          @new_resource.priv_password.nil?
        if @new_resource.engine_id.empty?
          @new_resource.groups(Cisco::SnmpUser.default_groups) if
            @new_resource.groups.nil?
        else
          @new_resource.groups([])
        end

        @new_resource.localized_key(false) if
          @new_resource.localized_key.nil?
      end

      def properties_differ?
        return true if @user.nil?
        return true if @new_resource.engine_id.empty? && @new_resource.groups.sort != @current_resource.groups.sort
        return true if @new_resource.auth_protocol != @current_resource.auth_protocol
        return true if @new_resource.priv_protocol != @current_resource.priv_protocol
        return true if @new_resource.engine_id != @current_resource.engine_id
        # auth/priv passwords can only be compared, not retrieved
        return true unless @user.auth_password_equal?(@new_resource.auth_password,
                                                      @new_resource.localized_key)
        return true unless @user.priv_password_equal?(@new_resource.priv_password,
                                                      @new_resource.localized_key)

        false
      end

      def action_destroy
        return if @user.nil?
        converge_by("remove snmp user instance with name #{@user.name} " +
                    (@user.engine_id.empty? ? '' : "engine id #{@user.engine_id}")) do
          @user.destroy
          @user = nil
        end
      end

      def whyrun_supported?
        true
      end
    end
  end
end
