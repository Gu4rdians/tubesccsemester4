Vagrant.configure("2") do |config|

  # ==========================================
  # 1. VM DATABASE (Dibuat Pertama)
  # ==========================================
  config.vm.define "vm-database" do |db|
    db.vm.box      = "bento/ubuntu-22.04"
    db.vm.hostname = "vm-database"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-database"
      vb.memory = "1024"
    end
  end

  # ==========================================
  # 2. VM BACKEND (Dibuat Kedua)
  # ==========================================
  config.vm.define "vm-backend" do |be|
    be.vm.box      = "bento/ubuntu-22.04"
    be.vm.hostname = "vm-backend"
    be.vm.network "private_network", ip: "192.168.56.10"
    be.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-backend"
      vb.memory = "1024"
    end
  end

  # ==========================================
  # 3. VM FRONTEND & CONTROL NODE (Dibuat Terakhir)
  # ==========================================
  config.vm.define "vm-frontend" do |fe|
    fe.vm.box      = "bento/ubuntu-22.04"
    fe.vm.hostname = "vm-frontend"
    fe.vm.network "private_network", ip: "192.168.56.12"
    fe.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-frontend"
      vb.memory = "1024"
    end

    # Install sshpass agar Ansible bisa masuk menggunakan password Vagrant secara otomatis
    fe.vm.provision "shell", inline: "apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sshpass"

    # Jalankan Ansible (limit="all" memastikan semua VM dikonfigurasi)
    fe.vm.provision "ansible_local" do |ansible|
      ansible.playbook       = "ansible/playbook.yml"
      ansible.inventory_path = "ansible/inventory"
      ansible.limit          = "all"
    end

    # Print Notifikasi Sukses dan URL di akhir eksekusi
    fe.vm.provision "shell", inline: <<-SHELL
      echo -e "\n\n"
      echo "================================================================="
      echo "🎯 DEPLOYMENT SELESAI & BERHASIL 100%!"
      echo "🌐 Aplikasi BMI Tracker kamu sudah menyala."
      echo "👉 Silakan CTRL+Click atau buka link ini di browser:"
      echo "   http://192.168.56.12"
      echo "================================================================="
      echo -e "\n\n"
    SHELL
  end

end