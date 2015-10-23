require_relative '../spec_helper'
require_relative '../helpers/matchers'
require 'chefspec'

describe 'cisco-cookbook::cisco_package_test_all' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new.converge(described_recipe)
  end

  it 'creates a cookbook_file' do
    expect(chef_run).to create_cookbook_file('/bootflash/bgp-dev-1.0.0-r0.lib32_n9000.rpm').with(
      owner:  'root',
      group:  'root',
      mode:   '0775',
      source: 'rpm-store/bgp-dev-1.0.0-r0.lib32_n9000.rpm',
    )
  end

  it 'test package install linux-style source path' do
    expect(chef_run).to create_cisco_package('bgp-dev').with(
      source: '/bootflash/bgp-dev-1.0.0-r0.lib32_n9000.rpm',
    )
  end

  it 'test package install short name' do
    expect(chef_run).to create_cisco_package('bgp-dev')
  end

  it 'test idempotence' do
    expect(chef_run).to create_cisco_package('bgp-dev')
  end

  it 'test package remove short name' do
    expect(chef_run).to remove_cisco_package('bgp-dev')
  end

  it 'test remove idempotence' do
    expect(chef_run).to remove_cisco_package('bgp-dev')
  end

  it 'test package install short name + arch' do
    expect(chef_run).to create_cisco_package('bgp-dev.lib32_n9000')
  end

  it 'test package remove short name + arch' do
    expect(chef_run).to remove_cisco_package('bgp-dev.lib32_n9000')
  end

  it 'test package install using package_name attribute' do
    expect(chef_run).to create_cisco_package('bgp-dev').with(
      package_name: 'bgp-dev',
    )
  end

  it 'test package remove using package_name attribute' do
    expect(chef_run).to remove_cisco_package('bgp-dev').with(
      package_name: 'bgp-dev',
    )
  end

  it 'test package remove linux-style source path' do
    expect(chef_run).to remove_cisco_package('bgp-dev').with(
      source: '/bootflash/bgp-dev-1.0.0-r0.lib32_n9000.rpm',
    )
  end
end
