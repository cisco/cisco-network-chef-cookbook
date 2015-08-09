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

require 'cisco_node_utils'

Ohai.plugin(:Cisco) do
  provides "cisco"

  collect_data(:linux) do #eventually :nexus
    cisco Mash.new

    cisco["images"] = {
      "system_image" => Platform.system_image,
      "packages"     => Platform.packages,
    }

    cisco["hardware"] = {
      "type"         => Platform.hardware_type,
      "cpu"          => Platform.cpu,
      "memory"       => Platform.memory,
      "board"        => Platform.board,
      "uptime"       => Platform.uptime,
      "last_reset"   => Platform.last_reset,
      "reset_reason" => Platform.reset_reason,
    }

    cisco["inventory"] = {}
    cisco["inventory"]["chassis"] = Platform.chassis
    Platform.slots.each{ |k,v| cisco["inventory"][k] = v }
    Platform.power_supplies.each{ |k,v| cisco["inventory"][k] = v }
    Platform.fans.each{ |k,v| cisco["inventory"][k] = v }

    cisco["virtual_service"] = Platform.virtual_services
  end
end
