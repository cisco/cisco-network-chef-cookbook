# January 2015, Alex Hunsberger
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

class Chef
  class Resource
    # CiscoVtp resource for Chef.
    class CiscoVtp < Chef::Resource
      attr_accessor :cisco_vtp

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_vtp
        @action = :create
        @allowed_actions = [:create, :destroy]
      end

      def domain(arg=nil)
        set_or_return(:domain, arg, kind_of: String)
      end

      def version(arg=nil)
        set_or_return(:version, arg, kind_of: Fixnum)
      end

      def filename(arg=nil)
        set_or_return(:filename, arg, kind_of: String)
      end

      def password(arg=nil)
        set_or_return(:password, arg, kind_of: String)
      end
    end
  end
end
