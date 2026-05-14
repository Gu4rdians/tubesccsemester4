Vagrant.configure("2") do |config|

  # 1. VM DATABASE
  config.vm.define "vm-database" do |db|
    db.vm.box      = "bento/ubuntu-22.04"
    db.vm.hostname = "vm-database"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-database"
      vb.memory = "1024"
      vb.gui    = true
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
      vb.gui    = true
    end
  end

  # 3. VM FRONTEND (Bertindak sebagai Control Node)
  config.vm.define "vm-frontend" do |fe|
    fe.vm.box      = "bento/ubuntu-22.04"
    fe.vm.hostname = "vm-frontend"
    fe.vm.network "private_network", ip: "192.168.56.12"
    fe.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-frontend"
      vb.memory = "1024"
      vb.gui    = true
    end

    # Install sshpass agar Ansible bisa menggunakan password auth
    fe.vm.provision "shell", inline: "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sshpass"

    # HANYA gunakan ansible_local di sini (berjalan di dalam VM Ubuntu)
    fe.vm.provision "ansible_local" do |ansible|
      ansible.playbook       = "ansible/playbook.yml"
      ansible.inventory_path = "ansible/inventory"
      ansible.limit          = "all"
    end
  end

  # PASTIKAN TIDAK ADA BLOK `config.vm.provision "ansible"` DI BAWAH SINI!
end