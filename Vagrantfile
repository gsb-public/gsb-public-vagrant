# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "gsb"
  #config.vm.box_url = "http://files.vagrantup.com/trusty32.box"
  #config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.network "private_network", ip: "10.100.101.102"

  config.vm.provider "virtualbox" do |v|
    #v.gui = true
    v.memory = 1024
  end
end
