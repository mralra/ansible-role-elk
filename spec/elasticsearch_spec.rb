# encoding: utf-8
require 'spec_helper'

describe file('/etc/apt/sources.list.d/'\
              'packages_elastic_co_elasticsearch_2_x_debian.list') do
  it { should be_file }
  its('mode') { should eq '644' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  repo_url = 'http://packages.elastic.co/elasticsearch/2.x/debian'
  its('content') { should include "deb #{repo_url}" }
end

describe package('elasticsearch') do
  it { should be_installed }
  # Might be a little aggressive to test for exact version number.
  its('version') { should >= '2.2.0' }
end
describe package('openjdk-7-jre-headless') do
  it { should be_installed }
end

describe file('/etc/elasticsearch/elasticsearch.yml') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'elasticsearch' }

  its('content') { should match(/^cluster\.name: elk-logging/) }
  its('content') { should match(/^network\.host: "localhost"/) }
  its('content') { should match(/^bootstrap\.mlockall: true/) }
end

describe service('elasticsearch') do
  it { should be_running }
  it { should be_enabled }
end

describe port(9200) do
  it { should be_listening.on('127.0.0.1') }
  it { should_not be_listening.on('0.0.0.0') }
end
