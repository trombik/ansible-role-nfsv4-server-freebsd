require "spec_helper"
require "serverspec"

package = "nfsv4-server-freebsd"
service = "nfsv4-server-freebsd"
config  = "/etc/nfsv4-server-freebsd/nfsv4-server-freebsd.conf"
user    = "nfsv4-server-freebsd"
group   = "nfsv4-server-freebsd"
ports   = [PORTS]
log_dir = "/var/log/nfsv4-server-freebsd"
db_dir  = "/var/lib/nfsv4-server-freebsd"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/nfsv4-server-freebsd.conf"
  db_dir = "/var/db/nfsv4-server-freebsd"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("nfsv4-server-freebsd") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/nfsv4-server-freebsd") do
    it { should be_file }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
