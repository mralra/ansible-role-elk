
# encoding: utf-8

control "elk-logstash-1.1" do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title "Install Logstash" # A human-readable title
  desc "The Logstash package should be present"

  describe apt("http://packages.elastic.co/logstash/2.1/debian") do
    it { should exist }
    it { should be_enabled }
  end

  describe package("logstash") do
    it { should be_installed }
    # Might be a little aggressive to test for exact version number.
    # Seeing an oddly formatted version number; ElasticSearch is simply '2.1.1'.
    its('version') { should >= '1:2.1.2-1' }
  end
end

control "elk-logstash-2.1" do
  impact 0.7
  title "Configure Logstash"
  desc "The Logstash service should be properly configured"

  describe file("/etc/logstash/conf.d") do
    it { should be_directory }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    it { should be_readable.by('others') }
    it { should_not be_writable.by('others') }
  end

  describe command("/opt/logstash/bin/logstash --configtest -f /etc/logstash/conf.d") do
    its('exit_status') { should eq 0 }
  end

  describe service("logstash") do
    it { should be_installed }
    it { should be_running }
    # TODO: Enabled check will always fail, since we're using sysv init script under Debian 8.
    # We could consider porting the init script to systemd, but there's a lot of traffic in the
    # Logstash GH issues about init script modifications, so let's get those upstream changes.
    # it { should be_enabled }
  end
  describe port(5000) do
    it { should be_listening }
    its('protocols') { should eq ['tcp'] }
    its('processes') { should eq ['java'] }
    # Although documented, the "addresses" attribute for the port resource type in inspec
    # isn't actually implemented. Using a command below as a workaround
#    its('addresses') { should include '0.0.0.0' }
  end
  describe command('ss -tl | grep 5000') do
    # Regular expressions are being finicky, may not be supported for stdout processing yet
    its('stdout') { should match /^LISTEN[\s\d]+\*:5000[\s*:]/ }
  end
end

