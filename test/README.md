# Testing using Test kitchen

## Requirements

 - ChefDK installed on local workstation
 - Switch under test available via SSH
 - Switch under test needs valid /etc/resolv.conf
 - Switch under test needs Internet access (for rubygems) via some VRF

## Setup

 - Checkout the complete cookbook, including the this "test" folder
 - Create a bundle environment to run the tests from using ```chef exec bundle``` from this main cookbook directory (the Gemfile there will be used to create the bundle)
 - Modify .kitchen.yml to point at switch under test's IP address and BASH login credentials
 - Modify .kitchen.yml to use appropriate VRF to connect to Internet via switch under test (if not management VRF)

## First run procedure

 - Converge test cookbook to switch and verify using serverspec using ```chef exec bundle exec kitchen converge``` from the cookbook directory
 - At this point, all tests should pass. You can cleanup by running ```chef exec bundle exec kitchen shutdown``` from the cookbook directory and removing /tmp/verifier directory on switch under test

## Second run procedures

 - If you have modified the test cookbook, you will need to run ```chef exec bundle exec kitchen converge``` from the cookbook directory again
 - If you are modifying the integration/helpers/serverspec_cisco/spec_helper.rb specinfra tests, then you will need to:
   - ```chef exec bundle exec kitchen setup``` from the cookbook directory to re-upload the new code
   - ```chef exec bundle exec kitchen verify``` from the cookbook directory to re-run the serverspec tests

## What's happening under the hood

Test Kitchen (TK) runs a "Test Cookbook" which will make changes on the test switch. Once that cookbook successfully converges, then TK runs serverspec_cisco to verify that that the test cookbook did what is expected. The purpose of TK is to test an entire cookbook, not every individual step in that cookbook along the way.
