require "spec_helper"

class ServiceNotReady < StandardError
end

sleep 10 if ENV["JENKINS_HOME"]

context "after provisioning finished" do
  describe server(:client1) do
    it "should be able to ping server" do
      result = current_server.ssh_exec("ping -c 1 #{server(:server1).server.address} && echo OK")
      expect(result).to match(/OK/)
    end
  end

  describe server(:server1) do
    it "should be able to ping client" do
      result = current_server.ssh_exec("ping -c 1 #{server(:client1).server.address} && echo OK")
      expect(result).to match(/OK/)
    end
  end

  describe server(:client1) do
    it "mounts NFS file system" do
      r = current_server.ssh_exec("sudo mount -t nfs -o ro #{server(:server1).server.address}:/usr/local /mnt")
      expect(r).to eq ""
    end

    it "shows the mounted file system" do
      r = current_server.ssh_exec("mount -t nfs")
      expect(r).to match(%r{#{server(:server1).server.address}:/usr/local on /mnt type nfs \(read-only, v3, udp, timeo=100, retrans=101\)$})
    end

    it "ls(1) sudoers under /mnt" do
      r = current_server.ssh_exec("ls /mnt/etc/sudoers")
      expect(r).to match(%r{^/mnt/etc/sudoers$})
    end

    it "umount the file system" do
      r = current_server.ssh_exec("sudo umount /mnt")
      expect(r).to eq ""
    end
  end
end
