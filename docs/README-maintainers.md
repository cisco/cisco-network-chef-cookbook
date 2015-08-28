# Maintainers Guide

Guidelines for the core maintainers of the cisco-cookbook project - above and beyond the [general developer guidelines](https://github.com/cisco/cisco-network-chef-cookbook/blob/develop/CONTRIBUTING.md).

## Accepting Pull Requests

* Is the pull request correctly submitted against the `develop` branch?
* Does `rubocop` pass? (TODO - this will be part of our CI integration to run automatically)
* Is `CHANGELOG.md` updated appropriately?
* Are new spec tests added? Do they provide sufficient coverage and consistent results?
* Are `demo_install.rb` and `demo_cleanup.rb` updated appropriately? 
* Do tests pass on both N9K and N3K? (In particular, N3048 often has unique behavior.)

## Setting up git-flow

If you don't already have [`git-flow`](https://github.com/petervanderdoes/gitflow/) installed, install it.

Either run `git flow init` from the repository root directory, or manually edit your `.git/config` file. Either way, when done, you should have the following in your config:

```ini
[gitflow "branch"]
        master = master
        develop = develop
[gitflow "prefix"]
        feature = feature/
        release = release/
        hotfix = hotfix/
        support = support/
        versiontag = v
```

Most of these are default for git-flow except for the `versiontag` setting.

## Release Process

When we agree as a team that a new release should be published, the process is as follows:

1. Ensure that [vendor gems](https://sethvargo.com/using-gems-with-chef/) included in the cookbook are up-to-date and reflect an official release version (development code in `develop` is OK, development code in a release is not!).

    ```
    gem uninstall --install-dir files/default/vendor cisco_node_utils cisco_nxapi
    gem install --install-dir files/default/vendor --no-document cisco_nxapi cisco_node_utils
    ```

2. Create a release branch. Follow [semantic versioning](http://semver.org) - a bugfix release is a 0.0.x version bump, a new feature is a 0.x.0 bump, and a backward-incompatible change is a new x.0.0 version. 

    ```
    git flow release start 1.0.1
    ```

3. In the newly created release branch, update `CHANGELOG.md`:

    ```diff
     Changelog
     =========
 
    -(unreleased)
    -------------
    +1.0.1
    +-----
    ```
    
    and also update `metadata.rb`:
    
    ```diff
    -  version '1.0.0'
    +  version '1.0.1'
    ```
    
4. Commit your changes and push the release branch to GitHub for review by Cisco and Chef Inc.:

	```
	git flow release publish 1.0.1
	```
	
5. Once Cisco and Chef Inc. are in agreement that the release branch is sane, finish the release and push the finished release to GitHub:

    ```
    git flow release finish 1.0.1
    git push origin master
    git push origin develop
    git push --tags
    ```

6. Add release notes on GitHub, for example `https://github.com/cisco/cisco-network-chef-cookbook/releases/new?tag=v1.0.1`. Usually this will just be a copy-and-paste of the relevant section of the `CHANGELOG.md`.