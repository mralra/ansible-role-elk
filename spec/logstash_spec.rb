# encoding: utf-8
require 'spec_helper'

describe file('/etc/apt/sources.list.d/'\
              'packages_elastic_co_logstash_2_2_debian.list') do
  it { should be_file }
  its('mode') { should eq '644' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  repo_url = 'http://packages.elastic.co/logstash/2.2/debian'
  its('content') { should include "deb #{repo_url}" }
end

describe package('logstash') do
  it { should be_installed }
  # Might be a little aggressive to test for exact version number.
  # Seeing an oddly formatted version number; ElasticSearch is simply '2.1.1'.
  its('version') { should >= '1:2.1.2-1' }
end

describe file('/etc/logstash/conf.d') do
  it { should be_directory }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  it { should be_readable.by('others') }
  it { should_not be_writable.by('others') }
end

describe command('/opt/logstash/bin/logstash --configtest \
                 -f /etc/logstash/conf.d') do
  its('exit_status') { should eq 0 }
end

describe service('logstash') do
  it { should be_enabled }
  it { should be_running }
end
describe port(5000) do
  it { should be_listening }
  its('protocols') { should eq ['tcp'] }
  its('processes') { should eq ['java'] }
  # Although documented, the "addresses" attribute for the port
  # resource type in inspec isn't actually implemented. Using a
  # command below as a workaround
  #  its('addresses') { should include '0.0.0.0' }
end
describe command('ss -tl | grep 5000') do
  # Regular expressions are being finicky, may not be
  # supported for stdout processing yet
  its('stdout') { should match(/^LISTEN[\s\d]+\*:5000[\s*:]/) }
end
