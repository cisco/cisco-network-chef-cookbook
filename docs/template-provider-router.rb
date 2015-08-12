#
# Cisco__CLASS_NAME__ provider for Chef
#
# Copyright (c) 2015 Cisco and/or its affiliates.
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
      @router = nil
      @name = new_resource.name
    end

    def whyrun_supported?
      true
    end

    # Find specific router instance with this name
    def load_current_resource
      @router = Cisco::__CLASS_NAME__.routers[@name]
    end

    def action_create
      if @router.nil?
        converge_by("create router '#{@name}'") {}
      end
      instantiate = whyrun_mode? ? false : true
      @router = Cisco::__CLASS_NAME__.new(@name, instantiate) if @router.nil?

      set_simple_properties
      set_complex_properties
    end

    # Simple properties: Most properties fit this category. Add new property
    # symbols to the array, generic_prop_set will call dynamic setter methods
    def set_simple_properties
      prop_set([:__PROPERTY_INT__, :__PROPERTY_BOOL__])
    end

    # Helper method to set properties
    def prop_set(props)
      Cisco::ChefUtils.generic_prop_set(self, "@router", props)
    end

    # Complex properties: includes compound properties and other complex
    # properties that require custom methods.

    def set_complex_properties
      # none
    end

    def action_destroy
      unless @router.nil?
        converge_by("destroy router #{@name}") do
          @router.destroy
          @router = nil
        end
      end
    end
  end
end
