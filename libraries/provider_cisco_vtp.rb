# January 2015, Alex Hunsberger
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
    # CiscoVtp provider for Chef.
    class CiscoVtp < Chef::Provider
      provides :cisco_vtp

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
        @vtp = nil
        @name = new_resource.name
        Chef::Log.debug "Cisco vtp #{@name}"
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        @vtp = Cisco::Vtp.new(false)
      end

      def action_create
        if Cisco::Vtp.enabled
          Chef::Log.debug 'feature vtp already enabled'
        else
          converge_by('enable feature vtp') {}
          return if whyrun_mode?
          @vtp.enable
        end
        @vtp = Cisco::Vtp.new if @vtp.nil?

        props = [:domain, :filename, :version, :password]
        Cisco::ChefUtils.generic_prop_set(self, '@vtp', props)
      end

      def action_destroy
        if Cisco::Vtp.enabled
          converge_by('disable vtp') do
            @vtp.destroy
            @vtp = nil
          end
        else
          Chef::Log.debug 'feature vtp already disabled'
        end
      end
    end
  end
end
