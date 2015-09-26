# Creating Cisco NX-OS Resources and Providers

#### Table of Contents

* [Overview](#overview)
* [Start here: Clone the Repo](#clone)
* [Basic Example: feature tunnel](#simple)
 * [Step 1. Type: feature tunnel](#res)
 * [Step 2. Provider: feature tunnel](#prov)
 * [Step 3. Testing: feature tunnel](#testing)
     * [node_utils API: tunnel.rb](#tunnel_api)
 * [Static Analysis](#lint)
* [Complex Example: router eigrp](#comp)
 * [Step 1. Type: router eigrp](#comp_res)
 * [Step 2. Provider: router eigrp](#comp_prov)
 * [Step 3. Testing: router eigrp](#comp_test)
     * [node_utils API: router_eigrp.rb](#eigrp_api)
 * [Static Analysis](#comp_lint)
* [Next Steps](#next)

## <a name="overview">Overview</a>

This document is a guide for writing new Chef resources and providers for Cisco NX-OS.

There are multiple components involved when creating new resources. This document focuses on the resource and provider files:

![1](tp_files.png)

* A resource is a statement of configuration policy. Each resource is associated with a [resource type][chef_res], which determines the kind of configuration it manages.

* Resource providers are essentially back-ends that implement support for a specific implementation of a given resource type.

* The resource types and providers work in conjunction with a node_utils API, which is the interface between the chef agent and the NX-OS CLI. Please see the [README-develop-node_utils-APIs.md][doc_nu] guide for more information on writing node_utils APIs.

This document relies heavily on example code. The exercises in this document can be written independently but they are intended to work in conjuction with the example node_utils APIs created in the [README-develop-node_utils-APIs.md][doc_nu] guide. The examples in that guide are based on code templates for the `feature tunnel` CLI and the `router eigrp` CLI. Note that some prefer to write the node_utils API before the resource types and providers while others may prefer the opposite workflow.

## <a name="clone">Start here: Clone the Repo</a>

Please see the [CONTRIBUTING](../CONTRIBUTING.md) document for workflow instructions. In general, you will need to fork the cisco-cookbook repository for your changes and submit a pull request when it is ready for commit.

First install the code base. Clone the cisco-cookbook repo into a workspace:

```bash
git clone https://github.com/chef-partners/cisco-cookbook
```

## <a name="simple">Basic Example: feature tunnel</a>

We will start with a very basic example. The NX-OS CLI for `feature tunnel` is a simple on / off style configuration:

`[no] feature tunnel`

This resource has no other properties.

*Note. This example disables the tunnel so you will need to use the guestshell environment when testing, or choose a different feature for this exercise.*

## <a name="res">Step 1. Resource: feature tunnel</a>

* Chef resource files for Cisco NX-OS are typically stored in the `libraries` directory using a convention that prefixes the filename with `resource_cisco_*`

*Note. Most cisco-cookbook resources are [HWRP resources][doc_hwrp], which is why they are found in the libraries directory.*

* There are template files in /docs that may help when writing new types and providers. These templates provide most of the necessary code with just a few customizations required for a new resource. Copy the `template-resource-feature.rb` file to use as the basis for our new `resource_cisco_tunnel.rb` type file:

```bash
cd  cisco-cookbook
cp  docs/template-resource-feature.rb  libraries/resource_cisco_tunnel.rb
```

* Edit `resource_cisco_tunnel.rb` and substitute the placeholder text as shown here:

```bash
/X__CLASS_NAME__X/Tunnel/

/X__RESOURCE_NAME__X/tunnel/
```

Note. There may be additional instructions within the template.

#### Example: resource_cisco_tunnel.rb

This is the completed tunnel resource file based on `template-resource-feature.rb`. This is a very simple resource to write since it has no additional properties.

~~~chef
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
    # CiscoTunnel resource for Chef
    class CiscoTunnel < Chef::Resource
      attr_accessor :exists, :cisco_tunnel

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_tunnel
        @name = name

        # Define the default action
        @action = :enable

        # List supported actions
        @allowed_actions = [:enable, :disable]
      end

    end
  end   # class Resource
end     # class Chef
~~~

## <a name="prov">Step 2. Provider: feature tunnel</a>

* Chef provider files for Cisco NX-OS are typically stored in the `libraries` directory using a convention that prefixes the filename with `provider_cisco_*`

* Use the `template-provider-feature.rb` file to use as the basis for our new `provider_cisco_tunnel.rb` type file:

```bash
cd  cisco-cookbook
cp  docs/template-provider-feature.rb  libraries/provider_cisco_tunnel.rb
```

* Edit `provider_cisco_tunnel.rb` and substitute the placeholder text as shown here:

```bash
/X__CLASS_NAME__X/Tunnel/

/X__RESOURCE_NAME__X/tunnel/

/X__CLI_NAME__X/tunnel/
```

#### Example: provider_cisco_tunnel.rb

This is the completed tunnel provider based on `template-provider-feature.rb`:

~~~chef
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
  class Provider
    # CiscoTunnel provider for Chef.
    class CiscoTunnel < Chef::Provider
      provides :cisco_tunnel

      def initialize(new_resource, run_context)
        super(new_resource, run_context)
      end

      def whyrun_supported?
        true
      end

      def load_current_resource
        @tunnel = Cisco::Tunnel.new
      end

      def action_enable
        return if Cisco::Tunnel.feature_enabled
        converge_by("enable feature tunnel") {}
        return if whyrun_mode?
        @tunnel.feature_enable
      end

      def action_disable
        return unless Cisco::Tunnel.feature_enabled
        converge_by("disable feature tunnel") do
          @tunnel.feature_disable
          @tunnel = nil
        end
      end
    end # class CiscoTunnel
  end # class Provider
end # class Chef
~~~

## <a name="testing">Step 3. Testing: feature tunnel</a>

This section assumes that a `tunnel.rb` node_utils API has already been written to work with our new tunnel resource and provider files. See [README-develop-node_utils-APIs.md][doc_nu] for more information on writing these APIs.

### <a name="tunnel_api">node_utils API: tunnel.rb</a>

The node_utils APIs become part of the cisco_node_utils gem, which is then installed directly into cisco-cookbook as a 'vendored' gem. Therefore, a new `tunnel.rb` API file will need to be installed in the cisco-cookbook using one of two methods:

##### Option A) If `tunnel.rb` is already part of cisco_node_utils gem:

Simply install the gem in your local cookbook workspace.

```bash
cd  cisco-cookbook

gem install --install-dir files/default/vendor/  \
            --no-rdoc  --no-ri   cisco_node_utils.gem
```

##### Option B) If `tunnel.rb` is not part of cisco_node_utils gem:

* First, copy `tunnel.rb` file to the proper cookbook directory.

```bash

cp tunnel.rb  \
   files/default/vendor/gems/cisco_node_utils-*/lib/cisco_node_utils/
```

* Then add a require statement to the list of node_utils resources by adding this line:
`require "cisco_node_utils/tunnel"`

To this file:
`files/default/vendor/gems/cisco_node_utils-*/lib/cisco_node_utils.rb`

### Recipe: cisco_tunnel

After the `tunnel.rb` API is installed you can create recipes to test the new resource and provider.

* Create a simple recipe to test feature enable:

```chef
cisco_tunnel "test_on" do
  action :enable
end
```

* Check the cli state on the NX-OS device prior to the chef run:

```bash
n9k# sh run | i 'feature tunnel'
n9k#
```

* Run chef


```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_tunnel[test_on] action enable
    - enable feature tunnel

Chef Client finished, 1/1 resources updated in 2.159415163 seconds
```

* Check cli state again

```bash
n9k# sh run | i 'feature tunnel'
feature tunnel
```

* The test was successful. Now add a recipe test for idempotency and feature disablement:

```chef
cisco_tunnel "test_on" do
  action :enable
end

cisco_tunnel "test_on_idempotent" do
  action :enable
end

cisco_tunnel "test_off" do
  action :disable
end

cisco_tunnel "test_off_idempotent" do
  action :disable
end
```

* Run chef

```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_tunnel[test_on] action enable (up to date)
  * cisco_tunnel[test_on_idempotent] action enable (up to date)
  * cisco_tunnel[test_off] action disable
    - disable feature tunnel
  * cisco_tunnel[test_off_idempotent] action disable (up to date)

Running handlers:
Running handlers complete
Chef Client finished, 1/4 resources updated in 2.347796694 seconds
```

## <a name="lint">Static Analysis</a>

Run [rubocop][doc_rubocop] to validate the new code.

```bash
% rubocop libraries/resource_cisco_tunnel.rb  \
          libraries/provider_cisco_tunnel.rb
Inspecting 2 files
..

2 files inspected, no offenses detected
```

## <a name="comp">Complex Example: router eigrp</a>

This resource and provider exercise will build on the router_eigrp API example shown in the cisco node_utils [README-develop-node_utils-APIs.md][doc_nu] document.

The router_eigrp node_utils example created a new API for the cli below:

```
[no] feature eigrp
[no] router eigrp [name]    (string)
       maximum-paths [n]    (integer)
  [no] shutdown             (boolean)
```

This exercise needs to support:

* multiple router eigrp instances, identified by 'name'
* an integer property
* a boolean property

Router eigrp also supports `vrf` and `address-family` sub-modes, which further complicate the configuration but are not included in this exercise.

The chef resource and provider code doesn't need any knowledge of `feature eigrp` because that configuration is controlled automatically by the router_eigrp node_utils API; therefore, we only need to implement the router commands themselves.

## <a name="comp_res">Step 1. Resource: router eigrp</a>

Copy the `template-resource-router.rb` file to use as the basis for our new `resource_cisco_router_eigrp.rb` resource file:

```bash
cd  cisco-cookbook
cp  docs/template-resource-router.rb  libraries/resource_cisco_router_eigrp.rb
```

* Edit `resource_cisco_router_eigrp.rb` and substitute the placeholder text as shown here:

```bash
/X__CLASS_NAME__X/RouterEigrp/

/X__RESOURCE_NAME__X/router_eigrp/

/X__PROPERTY_INT__X/maximum_paths/

/X__PROPERTY_BOOL__X/shutdown/
```

Note: There may be additional steps to follow in the template.

#### Example: resource_cisco_router_eigrp.rb

This is the completed router_eigrp resource based on `template-resource-router.rb`:

~~~chef
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
    # CiscoRouterEigrp resource for Chef
    class CiscoRouterEigrp < Chef::Resource
      attr_accessor     :cisco_router_eigrp

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_router_eigrp
        @name = name

        # Define default action
        @action = :create

        # Define list of supported actions
        @allowed_actions = [:create, :destroy]
      end

      def maximum_paths(arg=nil)
        set_or_return(:maximum_paths, arg, :kind_of=> Fixnum)
      end

      def shutdown(arg=nil)
        set_or_return(:shutdown, arg, :kind_of=>[TrueClass, FalseClass])
      end
    end
  end
end
~~~

## <a name="comp_prov">Step 2. Provider: router eigrp</a>

Copy the `template-provider-router.rb` file to use as the basis for our new `provider_cisco_router_eigrp.rb` provider file:

```bash
cd  cisco-cookbook
cp  docs/template-provider-router.rb  libraries/provider_cisco_router_eigrp.rb
```

* Edit `provider_cisco_router_eigrp.rb` and substitute the placeholder text as shown here:

```bash
/X__CLASS_NAME__X/RouterEigrp/

/X__RESOURCE_NAME__X/router_eigrp/

/X__PROPERTY_INT__X/maximum_paths/

/X__PROPERTY_BOOL__X/shutdown/
```

Note: There may be additional steps to follow in the template.

#### Example: provider_cisco_router_eigrp.rb

This is the completed router_eigrp provider based on `template-provider-router.rb`:

~~~chef
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
  class Provider
    # CiscoRouterEigrp provider for Chef
    class CiscoRouterEigrp < Provider
      provides :cisco_router_eigrp

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
        @router = Cisco::RouterEigrp.routers[@name]
      end

      def action_create
        converge_by("create router '#{@name}'") {} if @router.nil?
        instantiate = whyrun_mode? ? false : true
        @router = Cisco::RouterEigrp.new(@name, instantiate) if @router.nil?

        set_simple_properties
        set_complex_properties
      end

      # Simple properties: Most properties fit this category. Add new property
      # symbols to the array, generic_prop_set will call dynamic setter methods
      def set_simple_properties
        prop_set([:maximum_paths, :shutdown])
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
        return if @router.nil?
        converge_by("destroy router #{@name}") do
          @router.destroy
          @router = nil
        end
      end
    end
  end
end
~~~

## <a name="comp_test">Step 3. Testing: router eigrp</a>

Similar to the test setup for the simple tunnel example, this section assumes that a `router_eigrp.rb` node_utils API has already been written for our new router_eigrp resource and provider files. See [README-develop-node_utils-APIs.md][doc_nu] for more information on writing these APIs.

### <a name="eigrp_api">node_utils API: router_eigrp.rb</a>

Install or copy the `router_eigrp.rb` API file into the cisco-cookbook.
Please reference the [node_utils API: tunnel.rb](#tunnel_api) section for more information on installing node_utils API files.

### Recipe: cisco_router_eigrp

* Create a simple recipe to test the new cisco_router_eigrp resource:

```chef
cisco_router_eigrp "blue" do
  action :create
end
```

* Check the cli state on the NX-OS device prior to the chef run:

```bash
n9k# sh run eigrp
                         ^
% Invalid command at '^' marker.
```
*'Invalid command` is expected because the eigrp cli is not available when 'feature eigrp' is disabled*

* Run chef

```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_router_eigrp[blue] action create
    - create router 'blue'

Chef Client finished, 1/1 resources updated in 3.683306651 seconds

```

* Check cli state again

```bash
n9k# sh run eigrp
feature eigrp

router eigrp blue

```

* The test was successful. try changing properties and having multiple instances:

```chef
# Property tests
cisco_router_eigrp "blue" do
  maximum_paths  5
  shutdown       true
end

# 2nd instance
cisco_router_eigrp "red" do
  action        :create
  maximum_paths  7
  shutdown       false
end
```

```
n9k# no feature ei
n9k#
```

```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_router_eigrp[blue] action create
    - create router 'blue'
    - update maximum_paths '8' => '5'
    - update shutdown 'false' => 'true'
  * cisco_router_eigrp[red] action create
    - create router 'red'
    - update maximum_paths '8' => '7'

Chef Client finished, 2/2 resources updated in 5.79578624 seconds
```

```
n9k# sh run eigrp
feature eigrp

router eigrp blue
  maximum-paths 5
  shutdown
router eigrp red
  maximum-paths 7
```

* Test for idempotency

```
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_router_eigrp[blue] action create (up to date)
  * cisco_router_eigrp[red] action create (up to date)

Chef Client finished, 0/2 resources updated in 2.228111093 seconds
```

* Test removal

```chef
cisco_router_eigrp "blue" do
  action        :destroy
end

cisco_router_eigrp "red" do
  action        :destroy
end
```

* Run chef

```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_router_eigrp[blue] action destroy
    - destroy router blue
  * cisco_router_eigrp[red] action destroy
    - destroy router red

Chef Client finished, 2/2 resources updated in 5.935614121 seconds
```

```
n9k# sh run eigrp
                         ^
% Invalid command at '^' marker.
```

## <a name="comp_lint">Static Analysis</a>

Run [rubocop][doc_rubocop] to validate the new code.

```bash
% rubocop libraries/resource_cisco_router_eigrp.rb  \
          libraries/provider_cisco_router_eigrp.rb
Inspecting 2 files
..

2 files inspected, no offenses detected
```

## <a name="next">Next Steps</a>

Please see the [CONTRIBUTING](../CONTRIBUTING.md) document for code commit workflow instructions.

[chef_res]: https://docs.chef.io/resources.html
[doc_hwrp]: https://docs.chef.io/hwrp.html
[doc_nu]: https://github.com/cisco/cisco-network-node-utils/blob/master/docs/README-develop-node-utils-APIs.md
[doc_rubocop]: https://rubygems.org/gems/rubocop
