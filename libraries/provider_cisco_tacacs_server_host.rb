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

ENC_TYPE = {
  'none'      => Cisco::TACACS_SERVER_ENC_UNKNOWN,
  'clear'     => Cisco::TACACS_SERVER_ENC_NONE,
  'encrypted' => Cisco::TACACS_SERVER_ENC_CISCO_TYPE_7,
}

class Chef
  class Provider
    # CiscoTacacsServerHost provider for Chef.
    class CiscoTacacsServerHost < Chef::Provider
      provides :cisco_tacacs_server_host

      def whyrun_supported?
        true
      end

      def load_current_resource
        @host = Cisco::TacacsServerHost.hosts.values.find do |host|
          host.name == @new_resource.name
        end
      end

      def action_create
        if @host.nil?
          converge_by("Create tacacs server host '#{@new_resource.name}'") {}
          return if whyrun_mode?
        end
        @host = Cisco::TacacsServerHost.new(@new_resource.name) if @host.nil?

        # create also updates
        @new_resource.port(Cisco::TacacsServerHost.default_port) if
          @new_resource.port.nil?
        if @host.port != @new_resource.port
          converge_by "update port #{@host.port} => #{@new_resource.port}" do
            @host.port = @new_resource.port
          end
        end

        @new_resource.timeout(Cisco::TacacsServerHost.default_timeout) if
          @new_resource.timeout.nil?
        if @host.timeout != @new_resource.timeout
          converge_by "update timeout #{@host.timeout} => " +
            @new_resource.timeout.to_s do
            @host.timeout = @new_resource.timeout
          end
        end

        def_type_s = ENC_TYPE.key(
          Cisco::TacacsServerHost.default_encryption_type)
        type_s = ENC_TYPE.key(@host.encryption_type)

        # If neither encryption nor type specifed, treat it as no key configure;
        # otherwise, use default
        if @new_resource.encryption_type.nil? && @new_resource.encryption_password.nil?
          @new_resource.encryption_type('none')
        else
          @new_resource.encryption_type(def_type_s) if
            @new_resource.encryption_type.nil?
          @new_resource.encryption_password(
            Cisco::TacacsServerHost.default_encryption_password) if
              @new_resource.encryption_password.nil?
        end

        if @new_resource.encryption_type == 'default'
          encryption_type = def_type_s
        else
          encryption_type = @new_resource.encryption_type
        end
        return unless type_s != encryption_type ||
                      @host.encryption_password != @new_resource.encryption_password

        type_v = ENC_TYPE[encryption_type]
        if @new_resource.encryption_type == 'none'
          cb_msg = 'remove encryption key and password'
        else
          cb_msg = 'update encryption_type and password ' \
            "'#{@host.encryption_type} #{@host.encryption_password}' => " \
            "'#{type_v} #{@new_resource.encryption_password}'"
        end

        converge_by cb_msg do
          @host.encryption_key_set(type_v, @new_resource.encryption_password)
        end
      end

      def action_destroy
        return if @host.nil?
        converge_by('remove tacacs server host instance') do
          @host.destroy
          @host = nil
        end
      end
    end
  end
end
