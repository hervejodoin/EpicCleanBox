Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.host_name = "devhost"

  # config.vm.network :private_network, ip: "192.168.56.101"
  config.vm.network "public_network"
  config.ssh.forward_agent = true

  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--memory", 1024]
    v.customize ["modifyvm", :id, "--name", "devhost"]
  end

  config.vm.synced_folder "./", "/vagrant", disabled: true
  config.vm.synced_folder "./", "/var/www/webapp", id: "vagrant-root"
  config.vm.synced_folder "./laravel/app/storage", "/var/www/webapp/laravel/app/storage", id: "storage", :mount_options => ['dmode=777', 'fmode=777']

  config.vm.provision :shell, :path => "bootstrap.sh"

  # Set the Timezone to something useful
  config.vm.provision :shell, :inline => "echo \"America/Montreal\" | sudo tee /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata"

end
