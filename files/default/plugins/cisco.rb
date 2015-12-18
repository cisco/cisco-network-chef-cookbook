#
# cisco.rb
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

require 'chef'
# ensure cisco vendor gems are requirable by ohai
$LOAD_PATH.unshift(*Dir[Chef::Config.file_cache_path +
  '/cookbooks/cisco-cookbook/files/default/vendor/gems/*/lib'])
require 'cisco_node_utils'

Ohai.plugin(:Cisco) do
  provides 'cisco'

  collect_data(:linux) do # eventually :nexus
    cisco Mash.new

    cisco['images'] = {
      'system_image' => Cisco::Platform.system_image,
      'packages'     => Cisco::Platform.packages,
    }

    cisco['hardware'] = {
      'type'         => Cisco::Platform.hardware_type,
      'cpu'          => Cisco::Platform.cpu,
      'memory'       => Cisco::Platform.memory,
      'board'        => Cisco::Platform.board,
      'uptime'       => Cisco::Platform.uptime,
      'last_reset'   => Cisco::Platform.last_reset,
      'reset_reason' => Cisco::Platform.reset_reason,
    }

    cisco['inventory'] = {}
    cisco['inventory']['chassis'] = Cisco::Platform.chassis
    Cisco::Platform.slots.each { |k, v| cisco['inventory'][k] = v }
    Cisco::Platform.power_supplies.each { |k, v| cisco['inventory'][k] = v }
    Cisco::Platform.fans.each { |k, v| cisco['inventory'][k] = v }

    cisco['virtual_service'] = Cisco::Platform.virtual_services
  end
end
