# Revendor gems prior to release

Guidelines for the maintainers of the cisco-network-chef-cookbook project to revendor gems like cisco_node_utils in preparation for release. Vendored gems can be found in the `files/default/vendor/gems` directory.

1. Delete the old gem.
    ```
    cd files/default/vendor/gems/
    rm -rf cisco_node_utils-1.6.0
    ```
    
2. Delete `google-protobuf` and `grpc` gems from `files/default/vendor/gems` if they exist.
    ```
    rm -rf google-protobuf-3.0.2-x86_64-linux/
    rm -rf grpc-0.15.0-x86_64-linux/
    ```

3. Cleanup other directories under `files/default/vendor` and delete references to older gems.
    ```
    cd cache/
    rm -rf cisco_node_utils-1.6.0.gem
    rm -rf google-protobuf-3.0.2-x86_64-linux.gem
    rm -rf grpc-0.15.0-x86_64-linux.gem
    cd ../specifications/
    rm -rf cisco_node_utils*
    rm -rf google-protobuf*
    rm -rf grpc*
    ```
4. Install the new version of the gem.
    ```
    gem install --install-dir files/default/vendor --no-document cisco_node_utils
    ```
    
5. Repeat step 2 and 3 to remove `grpc` and `google-protobuf` if they were installed.

6. Add an entry to CHANGELOG.md to highlight the update to the vendored gem.
    ```
    ## [1.2.1] - 2017-09-21

    ### Added
    - Update the cisco_node_utils vendored gem to version [1.7.0](https://github.com/cisco/cisco-network-node-utils/blob/develop/CHANGELOG.md#v170).
    ```
