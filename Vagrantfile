Vagrant.configure("2") do |config|

  # 1. VM DATABASE
  config.vm.define "vm-database" do |db|
    db.vm.box      = "bento/ubuntu-22.04"
    db.vm.hostname = "vm-database"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-database"
      vb.memory = "1024"
    end
  end

  # 2. VM BACKEND
  config.vm.define "vm-backend" do |be|
    be.vm.box      = "bento/ubuntu-22.04"
    be.vm.hostname = "vm-backend"
    be.vm.network "private_network", ip: "192.168.56.10"
    be.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-backend"
      vb.memory = "1024"
    end

    # Sinkronisasi key agar backend bisa SSH ke frontend/database
    be.vm.provision "shell", inline: <<-SHELL
      mkdir -p /home/vagrant/.ssh
      cp /vagrant/ansible/insecure_private_key /home/vagrant/.ssh/id_rsa
      chmod 600 /home/vagrant/.ssh/id_rsa
      chown -R vagrant:vagrant /home/vagrant/.ssh
    SHELL
  end

  # 3. VM FRONTEND
  config.vm.define "vm-frontend" do |fe|
    fe.vm.box      = "bento/ubuntu-22.04"
    fe.vm.hostname = "vm-frontend"
    fe.vm.network "private_network", ip: "192.168.56.12"
    fe.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-frontend"
      vb.memory = "1024"
    end

    # TAMBAHKAN INI DI SINI agar frontend terinstal Nginx
    fe.vm.provision "ansible_local" do |ansible|
      ansible.playbook       = "ansible/playbook.yml"
      ansible.inventory_path = "ansible/inventory"
      ansible.limit           = "frontend"
    end
  end

end