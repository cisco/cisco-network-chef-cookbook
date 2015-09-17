# How to contribute
Cisco Network Elements support a rich set of features to make network robust, efficient and secure. This project enables Cisco Network Elements to be managed by Chef by defining a set of resource types and providers. This set is expected to grow with contributions from Cisco, Chef Inc and third-party alike. Contributions to this project are welcome. To ensure code quality, contributers will be requested to follow a few guidelines.

## Getting Started

* Create a [GitHub account](https://github.com/signup/free)
* Create a [cisco.com](http://cisco.com) account if you need access to a Network Simulator to test your code.

## Making Changes

* Fork the repository
* Pull a branch under the "**develop**" branch for your changes.
* Follow all guidelines documented in [README-develop-resources-providers.md](docs/README-develop-resources-providers.md)
* Make changes in your branch.
* Testing
  * Run all the tests to ensure there was no collateral damage to existing code.
  * Check for unnecessary whitespace with `git diff --check`
  * Run `rubocop` against all changed files. See [https://rubygems.org/gems/rubocop](https://rubygems.org/gems/rubocop)
* Ensure that your commit messages clearly describe the problem you are trying to solve and the proposed solution.

## Submitting Changes

* All contributions you submit to this project are voluntary and subject to the terms of the Apache 2.0 license
* Submit a pull request to the repository
* A core team consisting of Cisco and Chef Inc employees will review your pull request and provide feedback.
* After feedback has been given we expect responses within two weeks. After two weeks we may close the pull request if it isn't showing any activity.

# Additional Resources

* [General GitHub documentation](http://help.github.com/)
* [GitHub pull request documentation](http://help.github.com/send-pull-requests/)
* \#chef-hacking IRC channel on irc.freenode.org
* [chef-dev mailing list](http://lists.chef.io/sympa/info/chef-dev)
