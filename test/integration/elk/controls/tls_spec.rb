
# encoding: utf-8

control "elk-nginx-3.1" do # A unique ID for this control
  impact 0.7 # The criticality, if this control fails.
  title "Force TLS for Kibana interface" # A human-readable title
  desc "The Nginx reverse proxy for Kibana should use TLS"

  describe file("/etc/nginx/conf.d/kibana.conf") do
    it { should be_file }
    its('content') { should match /^\s+ssl_certificate \/[^\0]+;/ }
    its('content') { should match /^\s+ssl_certificate_key \/[^\0]+;/ }

    desired_ssl_config_lines = [
      'ssl_protocols TLSv1 TLSv1.1 TLSv1.2;',
      'ssl_prefer_server_ciphers on;',
      'ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";',
      'ssl_ecdh_curve secp384r1;',
      'ssl_session_cache shared:SSL:10m;',
      'ssl_session_tickets off;',
      'ssl_stapling on;',
      'ssl_stapling_verify on;',
      'resolver 127.0.0.1 valid=300s;',
      'resolver_timeout 5s;',
      'add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";',
      'add_header X-Frame-Options DENY;',
      'add_header X-Content-Type-Options nosniff;',
    ]
    desired_ssl_config_lines.each do |ssl_config_line|
      its('content') { should match /#{Regexp.quote(ssl_config_line)}/ }
    end
  end

  describe port(443) do
    it { should be_listening }
    its('protocols') { should eq ['tcp'] }
    its('processes') { should eq ['nginx'] }
    # Although documented, the "addresses" attribute for the port resource type in inspec
    # isn't actually implemented. Using a command below as a workaround
#    its('addresses') { should include '0.0.0.0' }
  end
  describe command('ss -tln | grep 443') do
    # Regular expressions are being finicky, may not be supported for stdout processing yet
    its('stdout') { should match /^LISTEN[\s\d]+\*:443[\s*:]/ }
  end
end

