#
# Cisco__CLASS_NAME__ resource for Chef
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

class Chef
  class Resource
    class Resource::Cisco__CLASS_NAME__ < Resource
      attr_accessor :cisco___RESOURCE_NAME__

      def initialize(name, run_context = nil)
        super
        @resource_name = :cisco___RESOURCE_NAME__
        @name = name

        # Define default action
        @action = :create

        # Define list of supported actions
        @allowed_actions = [:create, :destroy]
      end

      def __PROPERTY_INT__(arg = nil)
        set_or_return(:__PROPERTY_INT__, arg, :kind_of => Fixnum)
      end

      def __PROPERTY_BOOL__(arg = nil)
        set_or_return(:__PROPERTY_BOOL__, arg, :kind_of => [TrueClass, FalseClass])
      end
    end
  end
end
