#
# Cisco__CLASS_NAME__ provider for Chef.
#
# Copyright (c) 2014-2015 Cisco and/or its affiliates.
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

$:.unshift(*Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)])

require 'cisco_node_utils'

class Chef
  class Provider::Cisco__CLASS_NAME__ < Provider
    provides :cisco___RESOURCE_NAME__

    def initialize(new_resource, run_context)
      super(new_resource, run_context)
    end

    def whyrun_supported?
      true
    end

    def load_current_resource
      @__RESOURCE_NAME__ = Cisco::__CLASS_NAME__.new
    end

    def action_enable
      unless Cisco::__CLASS_NAME__.feature_enabled
        converge_by("enable feature __CLI_NAME__") {}
        return if whyrun_mode?
        @__RESOURCE_NAME__.feature_enable
      end
    end

    def action_disable
      if Cisco::__CLASS_NAME__.feature_enabled
        converge_by("disable feature __CLI_NAME__") do
          @__RESOURCE_NAME__.feature_disable
          @__RESOURCE_NAME__ = nil
        end
      end
    end
  end   # class Provider::Cisco__CLASS_NAME__
end     # class Chef
