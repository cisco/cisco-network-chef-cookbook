# Creating Cisco NX-OS Resources and Providers

#### Table of Contents

* [Overview](#overview)
* [Start here: Clone the Repo](#clone)
* [Basic Example: feature bash-shell](#simple)
 * [Step 1. Type: feature bash-shell](#res)
 * [Step 2. Provider: feature bash-shell](#prov)
 * [Step 3. Testing: feature bash-shell](#testing)
     * [node_utils API: bash_shell.rb](#bash_api)
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

![1](docs/tp_files.png)

* A resource is a statement of configuration policy. Each resource is associated with a [resource type][chef_res], which determines the kind of configuration it manages.

* Resource providers are essentially back-ends that implement support for a specific implementation of a given resource type.

* The resource types and providers work in conjunction with a node_utils API, which is the interface between the chef agent and the NX-OS CLI. Please see the [README-creating-node_utils-APIs.md][doc_nu] guide for more information on writing node_utils APIs.

This document relies heavily on example code. The exercises in this document can be written independently but they are intended to work in conjuction with the example node_utils APIs created in the [README-creating-node_utils-APIs.md][doc_nu] guide. The examples in that guide are based on code templates for the `feature bash-shell` CLI and the `router eigrp` CLI. Note that some prefer to write the node_utils API before the resource types and providers while others may prefer the opposite workflow.

## <a name="clone">Start here: Clone the Repo</a>

Please see the [CONTRIBUTING](#CONTRIBUTING) document for workflow instructions. In general, you will need to fork the cisco-cookbook repository for your changes and submit a pull request when it is ready for commit.

First install the code base. Clone the cisco-cookbook repo into a workspace:

```bash
git clone https://github.com/chef-partners/cisco-cookbook
```

## <a name="simple">Basic Example: feature bash-shell</a>

We will start with a very basic example. The NX-OS CLI for `feature bash-shell` is a simple on / off style configuration:

`[no] feature bash-shell`

This resource has no other properties.

*Note. This example disables the bash-shell so you will need to use the guestshell environment when testing, or choose a different feature for this exercise.*

## <a name="res">Step 1. Resource: feature bash-shell</a>

* Chef resource files for Cisco NX-OS are typically stored in the `libraries` directory using a convention that prefixes the filename with `resource_cisco_*`

*Note. Most cisco-cookbook resources are [HWRP resources][doc_hwrp], which is why they are found in the libraries directory.*

* There are template files in /docs that may help when writing new types and providers. These templates provide most of the necessary code with just a few customizations required for a new resource. Copy the `template-resource-feature.rb` file to use as the basis for our new `resource_cisco_bash_shell.rb` type file:

```bash
cd  cisco-cookbook
cp  docs/template-resource-feature.rb  libraries/resource_cisco_bash_shell.rb
```

* Edit `resource_cisco_bash_shell.rb` and substitute the placeholder text as shown here:

```bash
/X__CLASS_NAME__X/BashShell/

/X__RESOURCE_NAME__X/bash_shell/
```

Note. There may be additional instructions within the template.

#### Example: resource_cisco_bash_shell.rb

This is the completed bash_shell resource file based on `template-resource-feature.rb`. This is a very simple resource to write since it has no additional properties.

~~~chef
#
# CiscoBashShell resource for Chef
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
    class Resource::CiscoBashShell < Resource
      attr_accessor :exists, :cisco_bash_shell

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_bash_shell
        @name = name
        @action = :enable
        @allowed_actions = [:enable, :disable]
      end

    end
  end   # class Resource
end     # class Chef
~~~

## <a name="prov">Step 2. Provider: feature bash-shell</a>

* Chef provider files for Cisco NX-OS are typically stored in the `libraries` directory using a convention that prefixes the filename with `provider_cisco_*`

* Use the `template-provider-feature.rb` file to use as the basis for our new `provider_cisco_bash_shell.rb` type file:

```bash
cd  cisco-cookbook
cp  docs/template-provider-feature.rb  libraries/provider_cisco_bash_shell.rb
```

* Edit `provider_cisco_bash_shell.rb` and substitute the placeholder text as shown here:

```bash
/X__CLASS_NAME__X/BashShell/

/X__RESOURCE_NAME__X/bash_shell/

/X__CLI_NAME__X/bash-shell/
```

#### Example: provider_cisco_bash_shell.rb

This is the completed bash_shell provider based on `template-provider-feature.rb`:

~~~chef
#
# CiscoBashShell provider for Chef.
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
  class Provider::CiscoBashShell < Provider
    provides :cisco_bash_shell

    def initialize(new_resource, run_context)
      super(new_resource, run_context)
    end

    def whyrun_supported?
      true
    end

    def load_current_resource
      @bash_shell = Cisco::BashShell.new
    end

    def action_enable
      unless Cisco::BashShell.feature_enabled
        converge_by("enable feature bash-shell") {}
        return if whyrun_mode?
        @bash_shell.feature_enable
      end
    end

    def action_disable
      if Cisco::BashShell.feature_enabled
        converge_by("disable feature bash-shell") do
          @bash_shell.feature_disable
          @bash_shell = nil
        end
      end
    end

  end   # class Provider::CiscoBashShell
end     # class Chef
~~~

## <a name="testing">Step 3. Testing: feature bash-shell</a>

This section assumes that a `bash_shell.rb` node_utils API has already been written to work with our new bash_shell resource and provider files. See [README-creating-node_utils-APIs.md][doc_nu] for more information on writing these APIs.

### <a name="bash_api">node_utils API: bash_shell.rb</a>

The node_utils APIs become part of the cisco_node_utils gem, which is then installed directly into cisco-cookbook as a 'vendored' gem. Therefore, a new `bash_shell.rb` API file will need to be installed in the cisco-cookbook using one of two methods:

##### Option A) If `bash_shell.rb` is already part of cisco_node_utils gem:

Simply install the gem in your local cookbook workspace.

```bash
cd  cisco-cookbook

gem install --install-dir files/default/vendor/  \
            --no-rdoc  --no-ri   cisco_node_utils.gem
```

##### Option B) If `bash_shell.rb` is not part of cisco_node_utils gem:

* First, copy `bash_shell.rb` file to the proper cookbook directory.

```bash

cp bash_shell.rb  \
   files/default/vendor/gems/cisco_node_utils-0.9.0/lib/cisco_node_utils/
```

* Then add a require statement to the list of node_utils resources by adding this line:
`require "cisco_node_utils/bash_shell"`

To this file:
`files/default/vendor/gems/cisco_node_utils-0.9.0/lib/cisco_node_utils.rb`

### Recipe: cisco_bash_shell

After the `bash_shell.rb` API is installed you can create recipes to test the new resource and provider.

* Create a simple recipe to test feature enable:

```chef
cisco_bash_shell "test_on" do
  action :enable
end
```

* Check the cli state on the NX-OS device prior to the chef run:

```bash
n9k# sh run | i 'feature bash'
n9k#
```

* Run chef


```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_bash_shell[test_on] action enable
    - enable feature bash-shell

Chef Client finished, 1/1 resources updated in 2.159415163 seconds
```

* Check cli state again

```bash
n9k# sh run | i 'feature bash'
feature bash-shell
```

* The test was successful. Now add a recipe test for idempotency and feature disablement:

```chef
cisco_bash_shell "test_on" do
  action :enable
end

cisco_bash_shell "test_on_idempotent" do
  action :enable
end

cisco_bash_shell "test_off" do
  action :disable
end

cisco_bash_shell "test_off_idempotent" do
  action :disable
end
```

* Run chef

```chef
[root@guestshell chef]# chef-client
Starting Chef Client, version 12.4.1
 ...
Recipe: my_cookbook::my_recipe
  * cisco_bash_shell[test_on] action enable (up to date)
  * cisco_bash_shell[test_on_idempotent] action enable (up to date)
  * cisco_bash_shell[test_off] action disable
    - disable feature bash-shell
  * cisco_bash_shell[test_off_idempotent] action disable (up to date)

Running handlers:
Running handlers complete
Chef Client finished, 1/4 resources updated in 2.347796694 seconds
```

## <a name="lint">Static Analysis</a>

Run [rubocop][doc_rubocop] with the --lint option to validate the new code.

```bash
% rubocop --lint libraries/resource_cisco_bash_shell.rb  \
                 libraries/provider_cisco_bash_shell.rb
Inspecting 2 files
..

2 files inspected, no offenses detected
```

## <a name="comp">Complex Example: router eigrp</a>

This resource and provider exercise will build on the router_eigrp API example shown in the cisco node_utils [README-creating-node_utils-APIs][doc_nu] document.

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
#
# CiscoRouterEigrp resource for Chef
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
    class Resource::CiscoRouterEigrp < Resource
      attr_accessor     :cisco_router_eigrp

      def initialize(name, run_context=nil)
        super
        @resource_name = :cisco_router_eigrp
        @name = name
        @action = :create
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
#
# CiscoRouterEigrp provider for Chef
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
  class Provider::CiscoRouterEigrp < Provider
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
      if @router.nil?
        converge_by("create router '#{@name}'") {}
      end
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
      unless @router.nil?
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

Similar to the test setup for the simple bash_shell example, this section assumes that a `router_eigrp.rb` node_utils API has already been written for our new router_eigrp resource and provider files. See [README-creating-node_utils-APIs.md][doc_nu] for more information on writing these APIs.

### <a name="eigrp_api">node_utils API: router_eigrp.rb</a>

Install or copy the `router_eigrp.rb` API file into the cisco-cookbook.
Please reference the [node_utils API: bash_shell.rb](#bash_api) section for more information on installing node_utils API files.

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

Run [rubocop][doc_rubocop] with the --lint option to validate the new code.

```bash
% rubocop --lint libraries/resource_cisco_router_eigrp.rb  \
                 libraries/provider_cisco_router_eigrp.rb
Inspecting 2 files
..

2 files inspected, no offenses detected
```

## <a name="next">Next Steps</a>

Please see the [CONTRIBUTING](#CONTRIBUTING) document for code commit workflow instructions.

[chef_res]: https://docs.chef.io/resources.html
[doc_hwrp]: https://docs.chef.io/hwrp.html
[doc_nu]: https://github.com/cisco/cisco-network-node-utils/README-creating-node_utils-APIs.md
[doc_rubocop]: https://rubygems.org/gems/rubocop
