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
  # Logstash is one of the few services on the logserver that
  # that should accept external connections, rather than listening
  # only on localhost.
  it { should be_listening.on('0.0.0.0') }
  it { should_not be_listening.on('127.0.0.1') }
end
