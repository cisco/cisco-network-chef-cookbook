require 'spec_helper'

describe 'cisco-coobook' do
  #it 'installs a cisco-package' do
  #  expect(package('demo-one')).to be_installed
  #end

  it 'writes out a file using the file resource' do
    expect(file('/tmp/file_resource.txt')).to be_file
    expect(file('/tmp/file_resource.txt').md5sum).to eq '0bb1180130fb53d2d0d0bd45950863bf'
  end

  it 'writes out a file using the template resource' do
    expect(file('/tmp/template_resource.txt')).to be_file
    expect(file('/tmp/template_resource.txt').md5sum).to eq '4919580c509a7f0504d3e01fd84a0a08'
  end
end
