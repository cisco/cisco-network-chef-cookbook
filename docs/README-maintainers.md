# Maintainers Guide

Guidelines for the core maintainers of the cisco-cookbook project - above and beyond the [general developer guidelines](../CONTRIBUTING.md).

## Accepting Pull Requests

* Is the pull request correctly submitted against the `develop` branch?
* Does `rubocop` pass? (This is automatically checked by Travis-CI)
* Is `CHANGELOG.md` updated appropriately?
* Are new spec tests added? Do they provide sufficient coverage and consistent results?
* Are `demo_install.rb` and `demo_cleanup.rb` updated appropriately? 
* [Do tests pass on all supported platforms?](#test-platforms)

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

## Release Checklist

When we are considering publishing a new release, all of the following steps must be carried out (using the latest code base in `develop`):

1. Ensure that [vendor gems](https://sethvargo.com/using-gems-with-chef/) included in the cookbook are up-to-date and reflect an official release version (development code in `develop` is OK, development code in a release candidate is not!). Do a new gem release first if needed!

    ```
    gem uninstall --install-dir files/default/vendor cisco_node_utils cisco_nxapi
    gem install --install-dir files/default/vendor --no-document cisco_nxapi cisco_node_utils
    ```

2. <a name="test-platforms">Run all tests (demo recipes, serverspec, kitchen, etc.) against the latest software release or release candidate for each supported platform:</a>
  * N3k
  * N5k
  * N6k
  * N7k
  * N9k
  * N9k-F

3. Triage any test failures.

4. Make sure CHANGELOG.md accurately reflects all changes since the last release.
  * Add any significant changes that weren't documented in the changelog
  * Clean up any entries that are overly verbose, unclear, or otherwise could be improved.

## Release Process

When the release checklist above has been fully completed, the process for publishing a new release is as follows:

1. Create a release branch. Follow [semantic versioning](http://semver.org):
    * 0.0.x - a bugfix release
    * 0.x.0 - new feature(s)
    * x.0.0 - backward-incompatible change (only if unavoidable!)

    ```
    git flow release start 1.0.1
    ```

2. In the newly created release branch, update `CHANGELOG.md`:

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
    
3. Commit your changes and push the release branch to GitHub for review by Cisco and Chef Inc.:

	```
	git flow release publish 1.0.1
	```
	
4. Once Cisco and Chef Inc. are in agreement that the release branch is sane, finish the release and push the finished release to GitHub:

    ```
    git flow release finish 1.0.1
    git push origin master
    git push origin develop
    git push --tags
    ```

5. Add release notes on GitHub, for example `https://github.com/cisco/cisco-network-chef-cookbook/releases/new?tag=v1.0.1`. Usually this will just be a copy-and-paste of the relevant section of the `CHANGELOG.md`.

6. Reach out to Chef Inc. to publish the new version of the cookbook to Chef Supermarket.
