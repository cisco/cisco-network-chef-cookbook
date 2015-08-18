#
# resource_cisco_ospf_vrf.rb
#
# Author: Glenn F. Matthews
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
    class Resource::CiscoOspfVrf < Resource
      attr_accessor :ospf, :vrf

      @@title_pattern = /^(\w+)\s+(\w+)$/
      @@log_adj_choices = ['none', 'log', 'detail']

      def initialize(name, run_context)
        super
        @resource_name = :cisco_ospf_vrf
        @action = :create
        @allowed_actions = [:create, :destroy]
        @provider = Chef::Provider::CiscoOspfVrf
        validate_name(name.strip)
        @name = name.strip
        @ospf, @vrf = @@title_pattern.match(@name)[1, 2]
      end

      def validate_name(arg = nil)
        set_or_return(:name, arg, :kind_of => String, :callbacks => {
                        "name must be of the form '<ospf name> <vrf name>'" => lambda {
                          # match size will be 3 if both ospf and vrf are matched
                          |name| m = @@title_pattern.match(name); !m.nil? and m.size == 3
                        }
                      })
      end

      def auto_cost(arg = nil)
        set_or_return(:auto_cost, arg, :kind_of => Fixnum)
      end

      def default_metric(arg = nil)
        set_or_return(:default_metric, arg, :kind_of => Fixnum)
      end

      def log_adjacency(arg = nil)
        set_or_return(:log_adjacency, arg, :kind_of => String, :callbacks => {
                        "must be one of: [#{@@log_adj_choices.join(' ')}]" => lambda {
                          |mode| @@log_adj_choices.include? mode.downcase
                        }
                      })
      end

      def router_id(arg = nil)
        set_or_return(:router_id, arg, :kind_of => String, :callbacks => {
                        "must be a valid IPv4 address" => lambda {
                          |addr| addr.empty? or IPAddress.valid_ipv4? addr
                        }
                      })
      end

      def timer_throttle_lsa_start(arg = nil)
        set_or_return(:timer_throttle_lsa_start, arg, :kind_of => Fixnum)
      end

      def timer_throttle_lsa_hold(arg = nil)
        set_or_return(:timer_throttle_lsa_hold, arg, :kind_of => Fixnum)
      end

      def timer_throttle_lsa_max(arg = nil)
        set_or_return(:timer_throttle_lsa_max, arg, :kind_of => Fixnum)
      end

      def timer_throttle_spf_start(arg = nil)
        set_or_return(:timer_throttle_spf_start, arg, :kind_of => Fixnum)
      end

      def timer_throttle_spf_hold(arg = nil)
        set_or_return(:timer_throttle_spf_hold, arg, :kind_of => Fixnum)
      end

      def timer_throttle_spf_max(arg = nil)
        set_or_return(:timer_throttle_spf_max, arg, :kind_of => Fixnum)
      end
    end
  end
end
