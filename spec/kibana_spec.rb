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
  it { should be_listening.on('127.0.0.1') }
  it { should be_listening.with('tcp') }
  it { should_not be_listening.on('0.0.0.0') }
end
