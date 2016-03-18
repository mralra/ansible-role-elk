# encoding: utf-8
require 'spec_helper'

kibana_version = '4.4.1'

describe file("/opt/kibana-#{kibana_version}-linux-x64.tar.gz") do
  it { should exist }
  it { should be_file }
end

describe file("/opt/kibana-#{kibana_version}-linux-x64") do
  it { should exist }
  it { should be_directory }
  its('owner') { should eq 'www-data' }
  its('group') { should eq 'www-data' }
end

describe file('/opt/kibana') do
  it { should exist }
  it { should be_symlink }
  it { should be_linked_to "/opt/kibana-#{kibana_version}-linux-x64" }
end

describe file('/etc/systemd/system/kibana.service') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  it { should be_readable.by('others') }
  it { should_not be_writable.by('others') }

  desired_service_config_lines = [
    'Environment=NODE_OPTIONS="--max-old-space-size=200"',
    'User=www-data',
    'Environment=CONFIG_PATH=/opt/kibana/config/kibana.yml',
    'Environment=NODE_ENV=production'
  ]

  desired_service_config_lines.each do |config_line|
    its('content') { should include config_line }
  end
end

describe service('kibana') do
  it { should be_running }
  it { should be_enabled }
end
describe port(5601) do
  it { should be_listening }
  its('protocols') { should eq ['tcp'] }
  its('processes') { should eq ['node'] }
  # Although documented, the "addresses" attribute for the port
  # resource type in inspec isn't actually implemented. Using a
  # command below as a workaround.
  # its('addresses') { should include '0.0.0.0' }
end
describe command('ss -tl | grep 127.0.0.1:5601') do
  # Regular expressions are being finicky, may not be supported for
  # stdout processing yet. So let's just grep for the wanted string
  # and check the exit code.
  its('exit_status') { should eq 0 }
end
