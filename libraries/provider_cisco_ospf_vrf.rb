#
# provider_cisco_ospf_vrf.rb
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

$:.unshift *Dir[File.expand_path('../../files/default/vendor/gems/**/lib', __FILE__)]

require 'cisco_node_utils'

class Chef
  class Provider::CiscoOspfVrf < Provider
    provides :cisco_ospf_vrf

    def initialize(new_resource, run_context)
      super(new_resource, run_context)
      @ospf_vrf = nil
      new_resource.name.downcase!
    end

    def whyrun_supported?
      true
    end

    def load_current_resource
      # will return nil if no matching OSPF + VRF exists
      ospf_vrfs = Cisco::RouterOspfVrf.vrfs[new_resource.ospf]
      @ospf_vrf = ospf_vrfs.nil? ? nil :
        ospf_vrfs[new_resource.vrf]
    end

    def action_create
      Chef::Log.error "must specify OSPF name for #{@new_resource.name}" if
        new_resource.ospf.nil?
      Chef::Log.error "must specify VRF name for #{@new_resource.name}" if
        new_resource.vrf.nil?

      if @ospf_vrf.nil?
        converge_by ("create ospf vrf '#{@new_resource.ospf} " +
                                     "#{@new_resource.vrf}'") {} 
        return if whyrun_mode?
      end
      @ospf_vrf = Cisco::RouterOspfVrf.new(@new_resource.ospf,
                          @new_resource.vrf) if @ospf_vrf.nil?

      # default_metric is standard and can be generated
      props = [:default_metric]
      Cisco::ChefUtils.generic_prop_set(self, "@ospf_vrf", props)

      # set defaults
      @new_resource.auto_cost(cost_to_mbps(@ospf_vrf.default_auto_cost)) if
        @new_resource.auto_cost.nil?
      @new_resource.log_adjacency(@ospf_vrf.default_log_adjacency.to_s) if
        @new_resource.log_adjacency.nil?
      @new_resource.timer_throttle_lsa_start(
        @ospf_vrf.default_timer_throttle_lsa_start) if
        @new_resource.timer_throttle_lsa_start.nil?
      @new_resource.timer_throttle_lsa_hold(
        @ospf_vrf.default_timer_throttle_lsa_hold) if
        @new_resource.timer_throttle_lsa_hold.nil?
      @new_resource.timer_throttle_lsa_max(
        @ospf_vrf.default_timer_throttle_lsa_max) if
        @new_resource.timer_throttle_lsa_max.nil?
      @new_resource.timer_throttle_spf_start(
        @ospf_vrf.default_timer_throttle_spf_start) if
        @new_resource.timer_throttle_spf_start.nil?
      @new_resource.timer_throttle_spf_hold(
        @ospf_vrf.default_timer_throttle_spf_hold) if
        @new_resource.timer_throttle_spf_hold.nil?
      @new_resource.timer_throttle_spf_max(
        @ospf_vrf.default_timer_throttle_spf_max) if
        @new_resource.timer_throttle_spf_max.nil?

      curr_cost = cost_to_mbps(@ospf_vrf.auto_cost)
      unless @new_resource.auto_cost == curr_cost
        converge_by "update auto_cost #{curr_cost} " +
          "=> #{@new_resource.auto_cost}" do

          @ospf_vrf.auto_cost_set(@new_resource.auto_cost,
            Cisco::RouterOspfVrf::OSPF_AUTO_COST[:mbps])
        end
      end
      # default router_id doesn't make sense
      unless @new_resource.router_id.nil? or
        @ospf_vrf.router_id == @new_resource.router_id

        converge_by "update router_id #{@ospf_vrf.router_id} => " +
          @new_resource.router_id do

          @ospf_vrf.router_id = @new_resource.router_id
        end
      end
      unless @new_resource.log_adjacency == @ospf_vrf.log_adjacency.to_s
        converge_by "update log_adjacency #{@ospf_vrf.log_adjacency} => " +
          @new_resource.log_adjacency do

          @ospf_vrf.log_adjacency = @new_resource.log_adjacency.to_sym
        end
      end
      # timer_throttle_lsa start/hold/max must all be set at once
      unless @new_resource.timer_throttle_lsa_max ==
               @ospf_vrf.timer_throttle_lsa_max and
             @new_resource.timer_throttle_lsa_hold ==
               @ospf_vrf.timer_throttle_lsa_hold and
             @new_resource.timer_throttle_lsa_start ==
               @ospf_vrf.timer_throttle_lsa_start
        converge_by "update timer_throttle_lsa [start, hold, max] => " +
          "[#{@new_resource.timer_throttle_lsa_start}, " +
          "#{@new_resource.timer_throttle_lsa_hold}, " +
          "#{@new_resource.timer_throttle_lsa_max}]" do

          @ospf_vrf.timer_throttle_lsa_set(
            @new_resource.timer_throttle_lsa_start,
            @new_resource.timer_throttle_lsa_hold,
            @new_resource.timer_throttle_lsa_max)
        end
      end
      # timer_throttle_spf start/hold/max must all be set at once
      unless @new_resource.timer_throttle_spf_max ==
               @ospf_vrf.timer_throttle_spf_max and
             @new_resource.timer_throttle_spf_hold ==
               @ospf_vrf.timer_throttle_spf_hold and
             @new_resource.timer_throttle_spf_start ==
               @ospf_vrf.timer_throttle_spf_start
        converge_by "update timer_throttle_spf [start, hold, max] => " +
          "[#{@new_resource.timer_throttle_spf_start}, " +
          "#{@new_resource.timer_throttle_spf_hold}, " +
          "#{@new_resource.timer_throttle_spf_max}]" do

          @ospf_vrf.timer_throttle_spf_set(
            @new_resource.timer_throttle_spf_start,
            @new_resource.timer_throttle_spf_hold,
            @new_resource.timer_throttle_spf_max)
        end
      end
    end

    def action_destroy
      unless @ospf_vrf.nil?
        raise ArgumentError.new "use cisco_ospf to remove default vrf" if
          @new_resource.vrf == 'default'
        converge_by "destroy ospf vrf '#{@new_resource.name}'" do
          @ospf_vrf.destroy
          @ospf_vrf = nil
        end
      end
    end

    def cost_to_mbps(val_array)
      cost_value, cost_type = val_array
      # Cost_type is either gbps or mbps. If gbps, convert to mbps.
      cost_value *= 1000 if
        cost_type == Cisco::RouterOspfVrf::OSPF_AUTO_COST[:gbps]
      cost_value
    end
  end
end
