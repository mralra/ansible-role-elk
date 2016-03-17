# encoding: utf-8
require 'spec_helper'

describe package('nginx') do
  it { should be_installed }
  # Might be a little aggressive to test for exact version number.
  its('version') { should >= '1.6.2-5' }
end
describe file('/etc/nginx/conf.d/kibana.conf') do
  it { should be_file }
  its('owner') { should eq 'root' }
  its('group') { should eq 'root' }
  it { should be_readable.by('others') }

  desired_nginx_options = {
    'proxy_pass' => 'http://127.0.0.1:5601/',
    'auth_basic_user_file' => '/etc/nginx/conf.d/kibana.htpasswd'

  }
  desired_nginx_options.each do |k, v|
    regexp = /^\s+#{Regexp.quote(k)} #{Regexp.quote(v)};/
    its('content') { should match(regexp) }
  end
end

describe service('nginx') do
  it { should be_running }
  it { should be_enabled }
end

describe port(80) do
  # Nginx is one of the few services on the logserver that
  # that should accept external connections, rather than listening
  # only on localhost.
  it { should be_listening.on('0.0.0.0') }
  it { should be_listening.with('tcp') }
  it { should_not be_listening.on('127.0.0.1') }
end
