# -*- mode: ruby -*-
# vi: set ft=ruby :
MagentoPort = 9100
PhpMyAdminPort = 9200
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.provider :lxc do |v, override|
    v.backingstore = 'none'
    override.vm.box = "fgrehm/precise64-lxc"
  end

  config.vm.provider :virtualbox do |v, override|
    override.vm.box = "precise32"
    override.vm.box_url = "http://files.vagrantup.com/precise32.box"
  end

  config.vm.network "forwarded_port", guest: MagentoPort, host: MagentoPort
  config.vm.network "forwarded_port", guest: PhpMyAdminPort, host: PhpMyAdminPort

  config.vm.provision :shell, :path => "install_chef.sh" 

  config.vm.provision :chef_solo do |chef|
      chef.provisioning_path = "/etc/chef-solo"
      chef.add_recipe("ak-magento")
      chef.json = {
        :magento => {
            :port => MagentoPort,
            :magento_version => "1.7.0.2",
#            :demo_version => false,
        },
        :phpmyadmin => {:port => PhpMyAdminPort},
    }
  end
end
