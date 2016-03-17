# encoding: utf-8
require 'spec_helper'

describe file('/etc/nginx/conf.d/kibana.conf') do
  it { should be_file }
  its('content') { should match(%r{^\s+ssl_certificate \/[^\0]+;}) }
  its('content') { should match(%r{^\s+ssl_certificate_key \/[^\0]+;}) }

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
    'add_header Strict-Transport-Security \
    "max-age=63072000; includeSubdomains; preload";',
    'add_header X-Frame-Options DENY;',
    'add_header X-Content-Type-Options nosniff;'
  ]
  # TODO: Disabling the SSL config checks because the tests don't use a
  # self-signed cert, since there aren't prod SSL certs available for testing.
  if property['serverspec_elk_test_ssl']
    desired_ssl_config_lines.each do |ssl_config_line|
      its('content') { should match(/#{Regexp.quote(ssl_config_line)}/) }
    end
  end
end

describe port(443) do
  it { should be_listening.on('0.0.0.0') }
  it { should be_listening.with('tcp') }
  it { should_not be_listening.on('127.0.0.1') }
end
