require 'serverspec'

set :backend, :exec

def get_running_config(args=nil)
  `/isan/bin/vsh -c 'show running-config #{args}'`
end
