require "spec_helper"
require "serverspec"

services = %w[mountd nfsd nfsuserd rpcbind]
# XXX note that mountd and nfsuserd do not have a fixed port number
ports = [
  111, # rpcbind
  2049, # nfsd
]

default_ipv4_address = "10.0.2.15"
number_of_nfsd = 6

describe file("/etc/exports") do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  its(:content) { should match(%r{^V4:\s+/usr/local$}) }
  its(:content) { should match(%r{^/usr/local -sec=sys -ro -network 10\.0\.2\.0 -mask 255\.255\.255\.0$}) }
end

describe file "/etc/rc.conf" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  its(:content) { should match(/^nfs_server_enable="YES"$/) }
  its(:content) { should match(/^nfsv4_server_enable="YES"$/) }
  its(:content) { should match(/^mountd_enable="YES"$/) }
  its(:content) { should match(/^rpcbind_enable="YES"$/) }
  # XXX you cannot test "nfsd_enable" here as ansible do not bother to add the
  # line when the service is enabled by nfs_server_enable
end

describe file "/etc/rc.conf.d/rpcbind" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  its(:content) { should match(/^rpcbind_flags="-h #{default_ipv4_address}"$/) }
end

describe file "/etc/rc.conf.d/mountd" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  its(:content) { should match(/^mountd_flags="-r -S -l"$/) }
end

describe file "/etc/rc.conf.d/nfsd" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  # XXX note that nfs_server_flags instead of nfsd_flags
  its(:content) { should match(/^nfs_server_flags="-u -t -h #{default_ipv4_address} -n #{number_of_nfsd}"$/) }
end

describe file "/etc/rc.conf.d/nfsuserd" do
  it { should exist }
  it { should be_file }
  it { should be_owned_by "root" }
  it { should be_grouped_into "wheel" }
  it { should be_mode 644 }
  its(:content) { should match(/^nfsuserd_flags="-domain example\.org"$/) }
end

services.each do |service|
  describe service(service) do
    it { should be_running }
    it { should be_enabled } if service == "nfsuserd"
  end
end

describe process "mountd" do
  its(:user) { should eq "root" }
  its(:args) { should eq "/usr/sbin/mountd -r -S -l" }
end

describe process "rpcbind" do
  its(:user) { should eq "root" }
  its(:args) { should eq "/usr/sbin/rpcbind -h #{default_ipv4_address}" }
end

describe process "nfsd" do
  its(:user) { should eq "root" }
  # XXX in ps(1) output, the arguments are not shown. as such, cannot test the
  # arguments here
end

describe command "ps -axH -o command | grep '^nfsd: server'" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  slave_string = "nfsd: server (nfsd)\n" * number_of_nfsd
  its(:stdout) { should eq slave_string }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end

describe command "rpcinfo" do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/^\s+\d+\s+\d+\s+tcp\s+\S+\s+rpcbind\s+superuser$/) }
  its(:stdout) { should match(/^\s+\d+\s+\d+\s+udp\s+\S+\s+rpcbind\s+superuser$/) }
  its(:stdout) { should match(%r{^\s+\d+\s+\d+\s+local\s+/var/run/rpcbind\.sock\s+rpcbind\s+superuser$}) }
  its(:stdout) { should match(/^\s+\d+\s+\d+\s+tcp\s+\S+\s+mountd\s+superuser$/) }
  its(:stdout) { should match(/^\s+\d+\s+\d+\s+udp\s+\S+\s+mountd\s+superuser$/) }
  its(:stdout) { should match(/^\s+\d+\s+\d+\s+tcp\s+\S+\s+nfs\s+superuser$/) }
  its(:stdout) { should match(/^\s+\d+\s+\d+\s+udp\s+\S+\s+nfs\s+superuser$/) }
end
