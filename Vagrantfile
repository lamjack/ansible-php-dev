VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "chef/debian-7.7"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--accelerate3d", "off"]
    vb.customize ["modifyvm", :id, "--memory", 2048]
  end

  config.vm.network "private_network", ip: "10.1.2.3"
  config.vm.synced_folder ".", "/var/www", type: "nfs"
  config.vm.provision "shell", inline: "DEBIAN_FRONTEND=noninteractive; apt-get update; apt-get install -y python"
end
