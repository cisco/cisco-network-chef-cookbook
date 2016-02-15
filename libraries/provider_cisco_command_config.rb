# December 2014, Chris Van Heuveln
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
    # CiscoCommandConfig provider resource for Chef.
    #
    # The command_config provider provides best-effort support for free form
    # style configurations. There are limitations with this provider, such as
    # negating a non-existent configuration item, e.g. "no interface loopback1"
    # when the interface is not currently present in running-config; thus some
    # pre-processing of the recipe configuration is required to avoid these
    # acceptable failures.
    class CiscoCommandConfig < Chef::Provider
      provides :cisco_command_config
      attr_reader :new_resource

      include Cisco::ConfigParser

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @node = Cisco::Node.instance
        # @new_resource.name holds the configuration from the original recipe.
        # @min_config_str is the pre-processed, minimum config to apply to running
        @min_config_str = ''
        @name = new_resource.name
        Chef::Log.debug "Cisco commandconfig #{@name}"
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        Chef::Log.debug 'Load current resource for free-form configuration'
        @current_resource = Chef::Resource::CiscoCommandConfig.new(@name)

        running_config_str = @node.show('show running-config all')

        # Sanitize new config (from recipe)
        @new_resource.command.gsub!(/^\s*$\n/, '')

        # Compare full recipe config to running-config.
        recipe_hash = Configuration.new(@new_resource.command)
        running_hash = Configuration.new(running_config_str)
        existing_str = recipe_hash.compare_with(running_hash)

        if existing_str.include?(@new_resource.command)
          # The complete recipe config is already present in running-config
          @current_resource.exists = true

        else
          # Parts of the recipe config differ from running-config.
          # Detect which submode configs need to be applied.
          existing_hash = Configuration.new(existing_str)
          min_config_hash =
            Configuration.build_min_config_hash(existing_hash.configuration,
                                                recipe_hash.configuration)

          # Create minimum change set string from remaining config changes in hash
          @min_config_str = Configuration.config_hash_to_str(min_config_hash)

          @current_resource.exists = @min_config_str.empty? ? true : false
        end
      end

      def action_update
        if @current_resource.exists
          Chef::Log.debug "CommandConfig #{@name} already exists"
        else
          converge_by("apply CommandConfig changes (minimum changeset):\n" +
                      @min_config_str) do
            @node.config(@min_config_str)
          end
        end
      rescue Cisco::CliError => e
        Chef::Log.info "Successfully updated:\n#{e.previous.join("\n")}" \
          unless e.previous.empty?
        raise
      end
    end
  end
end
