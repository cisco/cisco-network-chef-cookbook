#
# CiscoX__CLASS_NAME__X provider for Chef.
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
  class Provider::CiscoX__CLASS_NAME__X < Provider
    provides :cisco_X__RESOURCE_NAME__X

    def initialize(new_resource, run_context)
      super(new_resource, run_context)
    end

    def whyrun_supported?
      true
    end

    def load_current_resource
      @X__RESOURCE_NAME__X = Cisco::X__CLASS_NAME__X.new
    end

    def action_enable
      unless Cisco::X__CLASS_NAME__X.feature_enabled
        converge_by("enable feature X__CLI_NAME__X") {}
        return if whyrun_mode?
        @X__RESOURCE_NAME__X.feature_enable
      end
    end

    def action_disable
      if Cisco::X__CLASS_NAME__X.feature_enabled
        converge_by("disable feature X__CLI_NAME__X") do
          @X__RESOURCE_NAME__X.feature_disable
          @X__RESOURCE_NAME__X = nil
        end
      end
    end
  end   # class Provider::CiscoX__CLASS_NAME__X
end     # class Chef
