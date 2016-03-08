
# encoding: utf-8

control "elk-elasticsearch-1.1" do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title "Install ElasticSearch" # A human-readable title
  desc "The Elasticsearch package should be present"

  describe apt("http://packages.elastic.co/elasticsearch/2.x/debian") do
    it { should exist }
    it { should be_enabled }
  end

  describe package("elasticsearch") do
    it { should be_installed }
    # Might be a little aggressive to test for exact version number.
    its('version') { should eq '2.2.0' }
  end
  describe package("openjdk-7-jre-headless") do
    it { should be_installed }
  end
end


control "elk-elasticsearch-2.1" do
  impact 0.7
  title "Configure ElasticSearch"
  desc "The Elasticsearch service should be properly configured"

  describe file("/etc/elasticsearch/elasticsearch.yml") do
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'elasticsearch' }

    its('content') { should match /^cluster\.name: elk-logging/ }
    its('content') { should match /^network\.host: "localhost"/ }
    its('content') { should match /^bootstrap\.mlockall: true/ }
  end

  describe service("elasticsearch") do
    it { should be_installed }
    it { should be_running }
    it { should be_enabled }
  end

  describe port(9200) do
    it { should be_listening }
    its('protocols') { should eq ['tcp'] }
    its('processes') { should eq ['java'] }
    # Although documented, the "addresses" attribute for the port resource type in inspec
    # isn't actually implemented. Using a command below as a workaround
#    its('addresses') { should include '127.0.0.1' }
  end
  describe command('ss -tl | grep 9200') do
    its('stdout') { should match /^LISTEN[\s\d]+127\.0\.0\.1:9200[\s*:]/ }
  end
end

