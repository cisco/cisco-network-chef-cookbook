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

$LOAD_PATH.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

TS_ENCRYPTION_TYPE_HASH = {
  'none'      => Cisco::TACACS_SERVER_ENC_UNKNOWN,
  'clear'     => Cisco::TACACS_SERVER_ENC_NONE,
  'encrypted' => Cisco::TACACS_SERVER_ENC_CISCO_TYPE_7,
}

class Chef
  class Provider
    # CiscoTacacsServer provider for Chef.
    class CiscoTacacsServer < Chef::Provider
      provides :cisco_tacacs_server

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        @tacacs_server = Cisco::TacacsServer.new(false)
      end

      def action_create
        if Cisco::TacacsServer.enabled
          Chef::Log.debug 'tacacs server already enabled'
        else
          converge_by('enable feature tacacs+') {}
          return if whyrun_mode?
          @tacacs_server.enable
        end
        action_update
      end

      def action_destroy
        if Cisco::TacacsServer.enabled
          # Only one instance of tacacs_server per box, just remove the feature
          converge_by('disable feature tacacs+') do
            @tacacs_server.destroy
          end
        else
          Chef::Log.debug 'tacacs server already disabled'
        end
      end

      def action_update
        # If a property isn't specified in the recipe, it will arrive here as a
        # nil object. In that case, set it to the default value and then compare.

        # Update timeout
        @new_resource.timeout(Cisco::TacacsServer.default_timeout) if
          @new_resource.timeout.nil?
        if @tacacs_server.timeout != @new_resource.timeout
          converge_by("update timeout from #{@tacacs_server.timeout} to " +
                      @new_resource.timeout.to_s) do
            @tacacs_server.timeout = @new_resource.timeout
          end
        end

        # Update deadtime
        @new_resource.deadtime(Cisco::TacacsServer.default_deadtime) if
          @new_resource.deadtime.nil?
        if @tacacs_server.deadtime != @new_resource.deadtime
          converge_by("update deadtime from #{@tacacs_server.deadtime} to " +
                      @new_resource.deadtime.to_s) do
            @tacacs_server.deadtime = @new_resource.deadtime
          end
        end

        # Update directed_request
        @new_resource.directed_request(Cisco::TacacsServer.default_directed_request) if
          @new_resource.directed_request.nil?
        if @tacacs_server.directed_request? != @new_resource.directed_request
          converge_by('update directed_request from ' \
                      "#{@tacacs_server.directed_request?} to " +
                      @new_resource.directed_request.to_s) do
            @tacacs_server.directed_request = @new_resource.directed_request
          end
        end

        # Update source_interface
        @new_resource.source_interface(Cisco::TacacsServer.default_source_interface) if
          @new_resource.source_interface.nil?
        if @tacacs_server.source_interface != @new_resource.source_interface
          converge_by('update source_interface from ' \
                      "#{@tacacs_server.source_interface} to " +
                      @new_resource.source_interface) do
            @tacacs_server.source_interface = @new_resource.source_interface
          end
        end

        # Update encryption_type and encryption_password
        # Get and save the default and current tacacs server type string.
        tacacs_server_def_type_string =
          TS_ENCRYPTION_TYPE_HASH.key(Cisco::TacacsServer.default_encryption_type)
        tacacs_server_type_string =
          TS_ENCRYPTION_TYPE_HASH.key(@tacacs_server.encryption_type)

        # If neither encryption type nor password is specified, treat it as
        # no password. Otherwise use default
        if @new_resource.encryption_type.nil? && @new_resource.encryption_password.nil?
          @new_resource.encryption_type('none')
        else
          @new_resource.encryption_type(tacacs_server_def_type_string) if
            @new_resource.encryption_type.nil?
          @new_resource.encryption_password(Cisco::TacacsServer.default_encryption_password) if
            @new_resource.encryption_password.nil?
        end

        return unless tacacs_server_type_string != @new_resource.encryption_type ||
                      @tacacs_server.encryption_password != @new_resource.encryption_password

        if @new_resource.encryption_type == 'default'
          new_resource_type_value = Cisco::TACACS_SERVER_ENC_NONE
        else
          new_resource_type_value =
            TS_ENCRYPTION_TYPE_HASH[@new_resource.encryption_type]
        end

        if @new_resource.encryption_type == 'none'
          cb_msg = 'Removing encryption key and password'
        else
          cb_msg = 'update encryption_type and password from ' \
            "'#{@tacacs_server.encryption_type}" \
            " #{@tacacs_server.encryption_password}' to " \
            "'#{new_resource_type_value} #{@new_resource.encryption_password}'"
        end

        converge_by(cb_msg) do
          @tacacs_server.encryption_key_set(new_resource_type_value,
                                            @new_resource.encryption_password)
        end
      end
    end
  end
end
