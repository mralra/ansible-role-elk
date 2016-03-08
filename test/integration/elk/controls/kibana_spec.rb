
# encoding: utf-8

control "elk-kibana-1.1" do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title "Install Kibana" # A human-readable title
  desc "The Kibana package should be present"

  describe file("/opt/kibana-4.3.1-linux-x64.tar.gz") do
    it { should exist }
    it { should be_file }
  end

  describe file("/opt/kibana-4.3.1-linux-x64") do
    it { should exist }
    it { should be_directory }
    its("owner") { should eq "www-data" }
    its("group") { should eq "www-data" }
  end

  describe file("/opt/kibana") do
    it { should exist }
    it { should be_symlink }
    it { should be_linked_to "/opt/kibana-4.3.1-linux-x64" }
  end
end

control "elk-kibana-2.1" do
  impact 0.7
  title "Configure Kibana"
  desc "The Kibana service should be properly configured"

  describe file("/etc/systemd/system/kibana.service") do
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    it { should be_readable.by('others') }
    it { should_not be_writable.by('others') }

    its('content') { should include 'Environment=NODE_OPTIONS="--max-old-space-size=200"' }
    its('content') { should include 'User=www-data' }
    its('content') { should include 'Environment=CONFIG_PATH=/opt/kibana/config/kibana.yml' }
    its('content') { should include 'Environment=NODE_ENV=production' }
  end

  describe service("kibana") do
    it { should be_installed }
    it { should be_running }
    it { should be_enabled }
  end
  describe port(5601) do
    it { should be_listening }
    its('protocols') { should eq ['tcp'] }
    its('processes') { should eq ['node'] }
    # Although documented, the "addresses" attribute for the port resource type in inspec
    # isn't actually implemented. Using a command below as a workaround
#    its('addresses') { should include '0.0.0.0' }
  end
  describe command('ss -tl | grep 127.0.0.1:5601') do
    # Regular expressions are being finicky, may not be supported for stdout processing yet.
    # So let's just grep for the wanted string and check the exit code.
    its('exit_status') { should eq 0 }
  end
end

