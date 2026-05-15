Vagrant.configure("2") do |config|

  # ==========================================
  # 1. VM DATABASE (Dibuat Pertama)
  # ==========================================
  config.vm.define "vm-database" do |db|
    db.vm.box      = "bento/ubuntu-22.04"
    db.vm.hostname = "vm-database"
    db.vm.network "private_network", ip: "192.168.56.11"
    
    db.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-database-bmi"
      vb.memory = "2048"
      vb.cpus   = 2
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
      vb.name   = "vm-backend-bmi"
      vb.memory = "2048"
      vb.cpus   = 2
    end
  end

  # ==========================================
  # 3. VM FRONTEND & CONTROL NODE (Terakhir)
  # ==========================================
  config.vm.define "vm-frontend" do |fe|
    fe.vm.box      = "bento/ubuntu-22.04"
    fe.vm.hostname = "vm-frontend"
    fe.vm.network "private_network", ip: "192.168.56.12"

    fe.vm.provider "virtualbox" do |vb|
      vb.name   = "vm-frontend-bmi"
      vb.memory = "2048"
      vb.cpus   = 2
    end

    # Install dependencies dan auto-enkripsi secrets.yml sebelum Ansible jalan
    fe.vm.provision "shell", inline: <<-SHELL
      apt-get update -qq
      DEBIAN_FRONTEND=noninteractive apt-get install -y sshpass ansible

      SECRETS_FILE="/vagrant/ansible/vars/secrets.yml"
      VAULT_PASS="/vagrant/ansible/vault_password.txt"

      if [ -f "$SECRETS_FILE" ]; then
        if grep -q "ANSIBLE_VAULT" "$SECRETS_FILE"; then
          echo "✅ secrets.yml sudah terenkripsi, skip enkripsi."
        else
          echo "🔐 Mengenkripsi secrets.yml dengan Ansible Vault..."
          ansible-vault encrypt "$SECRETS_FILE" --vault-password-file "$VAULT_PASS"
          echo "✅ secrets.yml berhasil dienkripsi!"
        fi
      else
        echo "⚠️  WARNING: File $SECRETS_FILE tidak ditemukan!"
        exit 1
      fi
    SHELL

    # Jalankan Ansible dari dalam VM frontend ini!
    fe.vm.provision "ansible_local" do |ansible|
      ansible.playbook          = "ansible/playbook.yml"
      ansible.inventory_path    = "ansible/inventory"
      ansible.limit             = "all"
      ansible.vault_password_file = "ansible/vault_password.txt"
    end

    # Pesan sukses
    fe.vm.provision "shell", inline: <<-SHELL
      echo -e "\n\n"
      echo "================================================================="
      echo "🎯 DEPLOYMENT BMI TRACKER SELESAI & BERHASIL 100%!"
      echo "👉 Silakan buka link ini di browser: http://192.168.56.12"
      echo "================================================================="
      echo -e "\n\n"
    SHELL
  end 

end