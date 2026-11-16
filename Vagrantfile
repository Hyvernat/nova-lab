# -*- mode: ruby -*-
# vi: set ft=ruby :
# Vagrantfile : laboratoire NOVA - 3 machines : ctrl + preprod + prod

# 1) Le tableau des machines : nom => paramètres
NODES = {
  "ctrl"    => { ip: "192.168.56.10", cpus: 1, memory: 1024, script: "provision-ctrl.sh" },
  "preprod" => { ip: "192.168.56.21", cpus: 2, memory: 2048, script: "provision-node.sh" },
  "prod"    => { ip: "192.168.56.22", cpus: 2, memory: 2048, script: "provision-node.sh" },
}

Vagrant.configure("2") do |config|
  # 2) Réglages communes aux 3 machines
  config.vm.box = "bento/ubuntu-22.04"      # image de départ : Ubuntu 22.04
  config.vm.box_check_update = false    
    config.vm.boot_timeout = 600  # 10 min max pour démarrer (labo lent)   # pas de vérification réseau à chaque démarrage
  config.vm.synced_folder ".", "/vagrant"   # ton dossier nov-lab est visible dans les VM sous /vagrant

  # 3) La boucle : une VM créée pour chaque ligne du tableau
  NODES.each do |name, cfg|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network "private_network", ip: cfg[:ip]   # réseau privé entre ton PC et les VM

      node.vm.provider "virtualbox" do |vb|
        vb.name   = "nova-#{name}"          # nom affiché dans VirtualBox
        vb.cpus   = cfg[:cpus]
        vb.memory = cfg[:memory]
        vb.linked_clone = true              # les VM partagent un disque de base : gain de place
      end

      # 4) Le script d'installation lancé au 1er démarrage
      node.vm.provision "shell", path: "scripts/#{cfg[:script]}"
    end
  end
end