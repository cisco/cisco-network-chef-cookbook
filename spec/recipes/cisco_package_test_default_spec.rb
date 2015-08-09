require_relative '../spec_helper'
require_relative '../helpers/matchers'
require 'chefspec'

describe 'ciscolib_nxos::cisco_package_test_default' do
    let(:chef_run) do
 ChefSpec::SoloRunner.new.converge(described_recipe)
    end

it 'package tester' do
  expect(chef_run).to create_cisco_package('package-tester').with(
    source: '/bootflash/package-tester-4.1.1-r4.x86_64.rpm'
   )
end

end
