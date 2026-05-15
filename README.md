# 🏥 BMI Tracker — Aplikasi Kalkulator Gizi Berbasis Multi-VM

> Aplikasi web full-stack untuk menghitung, menyimpan, dan menganalisis Body Mass Index (BMI) secara cerdas menggunakan AI. Dibangun di atas infrastruktur **3 Virtual Machine** yang di-provision otomatis menggunakan **Vagrant + Ansible**.

---

## 📋 Deskripsi Aplikasi

**BMI Tracker** adalah aplikasi kesehatan berbasis web yang memungkinkan pengguna untuk:

- 🧮 **Menghitung BMI** menggunakan dua metode:
  - **Standar WHO/CDC** untuk dewasa (≥ 20 tahun)
  - **Persentil CDC** untuk anak & remaja (2–19 tahun)
- 💾 **Menyimpan riwayat** hasil perhitungan ke database MySQL
- 📊 **Menampilkan riwayat** perhitungan dari semua pengguna
- 🤖 **Konsultasi AI** menggunakan Google Gemini untuk analisis gizi dan rekomendasi kesehatan berbasis data BMI pengguna

---

## 🏗️ Arsitektur Sistem — 3 Virtual Machine

Aplikasi ini menggunakan arsitektur **terdistribusi berbasis 3 VM** yang saling terhubung dalam jaringan private (`192.168.56.0/24`):

```
┌─────────────────────────────────────────────────────────────┐
│                   HOST MACHINE (Windows)                    │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Private Network: 192.168.56.0/24        │   │
│  │                                                      │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │   │
│  │  │  VM DATABASE │  │  VM BACKEND  │  │VM FRONTEND│  │   │
│  │  │192.168.56.11 │  │192.168.56.10 │  │192.168.56│  │   │
│  │  │              │  │              │  │   .12    │  │   │
│  │  │   MySQL 8.0  │◄─│  Python Flask│◄─│  Nginx   │  │   │
│  │  │   db_bmi     │  │  + Gemini AI │  │  HTML/JS │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │   │
│  │         Port 3306        Port 5000        Port 80   │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  Browser User → http://192.168.56.12                       │
└─────────────────────────────────────────────────────────────┘
```

---

## 🖥️ Pembagian Fungsi Tiap VM

### 🗄️ VM Database — `192.168.56.11`
| Atribut | Detail |
|---|---|
| **OS** | Ubuntu 22.04 (bento/ubuntu-22.04) |
| **RAM** | 2 GB |
| **Software** | MySQL Server 8.0 |
| **Database** | `db_bmi` |
| **User DB** | `user_bmi` / `password_bmi` |
| **Akses Remote** | `bind-address = 0.0.0.0` (menerima koneksi dari semua IP) |

**Tabel yang dibuat:**
```sql
CREATE TABLE riwayat_bmi (
  id        INT AUTO_INCREMENT PRIMARY KEY,
  nama      VARCHAR(255) NOT NULL,
  umur      INT NOT NULL,
  berat     DECIMAL(5, 2) NOT NULL,
  tinggi    DECIMAL(5, 2) NOT NULL,
  bmi       DECIMAL(5, 2) NOT NULL,
  kategori  VARCHAR(100) NOT NULL,
  tanggal   DATETIME NOT NULL
);
```

---

### ⚙️ VM Backend — `192.168.56.10`
| Atribut | Detail |
|---|---|
| **OS** | Ubuntu 22.04 |
| **RAM** | 2 GB |
| **Framework** | Python Flask |
| **Port** | `5000` |
| **AI** | Google Gemini 2.5 Flash (`google-generativeai`) |

**REST API Endpoints:**

| Method | Endpoint | Fungsi |
|---|---|---|
| `POST` | `/api/bmi` | Hitung BMI + simpan ke DB |
| `GET` | `/api/bmi` | Ambil seluruh riwayat dari DB |
| `POST` | `/api/chat` | Kirim pesan ke Gemini AI |

**Logika BMI:**
- Umur ≥ 20 tahun → Metode **Standar WHO/CDC** (Kurus / Normal / Gemuk / Obesitas)
- Umur < 20 tahun → Metode **Persentil CDC** (Underweight / Normal / Overweight / Obesitas berdasarkan persentil)

---

### 🌐 VM Frontend — `192.168.56.12`
| Atribut | Detail |
|---|---|
| **OS** | Ubuntu 22.04 |
| **RAM** | 2 GB |
| **Web Server** | Nginx |
| **Port** | `80` |
| **Teknologi** | HTML5, CSS3 (Vanilla), JavaScript (ES6+) |
| **Font** | Plus Jakarta Sans (Google Fonts) |

**Fitur UI:**
- Form kalkulator BMI (Nama, Umur, Berat, Tinggi)
- Hasil BMI dengan indikator warna per kategori
- Label metode dengan ikon SVG (👤 Dewasa / ℹ Anak & Remaja)
- Tabel referensi BMI (Dewasa + CDC Anak & Remaja dengan kolom Persentil)
- Riwayat perhitungan real-time dari database
- Chat AI (Gemini) terintegrasi dalam halaman

> VM Frontend juga berfungsi sebagai **Ansible Control Node** — menjalankan Ansible untuk mengkonfigurasi VM lainnya.

---

## 🛠️ Tools & Teknologi

| Kategori | Teknologi |
|---|---|
| **Virtualisasi** | [VirtualBox](https://www.virtualbox.org/) |
| **Manajemen VM** | [Vagrant](https://www.vagrantup.com/) |
| **Provisioning** | [Ansible](https://www.ansible.com/) |
| **Keamanan Secrets** | [Ansible Vault](https://docs.ansible.com/ansible/latest/cli/ansible-vault.html) (enkripsi AES-256) |
| **Database** | MySQL 8.0 |
| **Backend** | Python 3, Flask, Flask-CORS, mysql-connector-python |
| **AI** | Google Gemini (`google-generativeai`) |
| **Frontend** | HTML5, CSS3, JavaScript, Nginx |
| **OS VM** | Ubuntu 22.04 LTS (bento/ubuntu-22.04) |

---

## 📁 Struktur Proyek

```
tubesccsemester4/
├── Vagrantfile                  # Definisi 3 VM + provisioner
├── .gitignore                   # Mengecualikan vault_password.txt & .vagrant/
└── ansible/
    ├── inventory                # Daftar host (database, backend, frontend)
    ├── playbook.yml             # Playbook utama (3 play)
    ├── vault_password.txt       # 🔒 TIDAK di-commit (ada di .gitignore)
    └── vars/
        └── secrets.yml          # API key Gemini (terenkripsi AES-256)
```

---

## 📖 Struktur Playbook (`ansible/playbook.yml`)

Playbook terdiri dari **3 Play** yang berjalan berurutan:

### Play 1 — Konfigurasi VM Database (`hosts: database`)
```
1. Install mysql-server
2. Konfigurasi bind-address = 0.0.0.0 (remote access)
3. Buat file struktur.sql (CREATE DATABASE, USER, TABLE)
4. Eksekusi struktur.sql ke MySQL
5. Verifikasi tabel riwayat_bmi
6. Restart MySQL (systemd)
```

### Play 2 — Konfigurasi VM Backend (`hosts: backend`)
```
1. Load vars_files: vars/secrets.yml (dekripsi Ansible Vault)
2. Install: python3-pip, python3-flask, python3-flask-cors, python3-mysql.connector
3. Install google-generativeai via pip
4. Deploy app.py (Flask API dengan Gemini AI)
   ├── CustomJSONEncoder (fix Decimal + datetime dari MySQL)
   ├── GET /api/bmi  → ambil riwayat dari MySQL
   ├── POST /api/bmi → hitung BMI + simpan ke MySQL
   └── POST /api/chat → generate response dari Gemini AI
5. Buat systemd service (bmibackend.service)
6. Reload systemd + enable + start service
```

### Play 3 — Konfigurasi VM Frontend (`hosts: frontend`)
```
1. Install Nginx
2. Deploy index.html ke /var/www/html/
   ├── Form kalkulator BMI
   ├── Tabel referensi (Dewasa + CDC Anak & Remaja)
   ├── Riwayat perhitungan (fetch dari backend)
   └── Chat AI Gemini terintegrasi
3. Set permission file HTML (chmod 644)
```

---

## 🔐 Keamanan API Key — Ansible Vault

API key Google Gemini **tidak pernah disimpan dalam plaintext** di repository. Berikut mekanisme enkripsinya:

### Cara Kerja

```
secrets.yml (plaintext)
    │
    ▼  ansible-vault encrypt (AES-256)
secrets.yml (ciphertext) ✅ aman di GitHub
    │
    ▼  Saat vagrant up (vault_password.txt sebagai script)
app.py mendapat API key asli (hanya di dalam VM, tidak pernah ke disk host)
```

### File yang terlibat

| File | Status GitHub | Keterangan |
|---|---|---|
| `ansible/vars/secrets.yml` | ✅ **Di-commit** (terenkripsi) | Berisi `gemini_api_key` dalam format AES-256 |
| `ansible/vault_password.txt` | ❌ **Diabaikan** (`.gitignore`) | Script shell yang mengeluarkan password vault |

### Isi `vault_password.txt` (dibuat manual, tidak di-commit)
```sh
#!/bin/sh
printf '%s' 'rahasia_vault_bmi_2026'
```

> ⚠️ File ini **harus dibuat manual** oleh setiap anggota tim setelah `git clone`. Bagikan password melalui jalur aman (bukan GitHub).

### Mengapa menggunakan shell script, bukan file teks biasa?
VirtualBox shared folder secara otomatis memberikan **executable bit** pada semua file yang disync dari Windows ke Linux. Ansible memperlakukan file executable sebagai *script* yang harus dijalankan untuk menghasilkan password. Dengan format `#!/bin/sh` + `printf`, file ini menjadi script yang valid.

### Cara enkripsi ulang (jika API key diganti)
```bash
# Edit secrets.yml dengan API key baru
nano ansible/vars/secrets.yml

# Enkripsi
ansible-vault encrypt ansible/vars/secrets.yml \
  --vault-password-file ansible/vault_password.txt

# Verifikasi (harus tampil $ANSIBLE_VAULT;1.1;AES256)
cat ansible/vars/secrets.yml
```

---

## 🚀 Cara Instalasi & Menjalankan

### Prasyarat
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads) ≥ 6.1
- [Vagrant](https://www.vagrantup.com/downloads) ≥ 2.3
- Git
- RAM minimal **8 GB** (3 VM × 2 GB + overhead)

### Langkah 1 — Clone Repository
```bash
git clone https://github.com/Gu4rdians/tubesccsemester4.git
cd tubesccsemester4
```

### Langkah 2 — Buat File `vault_password.txt`
> ⚠️ File ini tidak tersedia di repository. Buat manual:

```bash
# Buat file
cat > ansible/vault_password.txt << 'EOF'
#!/bin/sh
printf '%s' 'rahasia_vault_bmi_2026'
EOF
```

> Minta password vault kepada anggota tim lain melalui jalur aman jika berbeda dari contoh di atas.

### Langkah 3 — Jalankan Vagrant
```bash
vagrant up
```

Proses ini akan otomatis:
1. Membuat 3 VM (database, backend, frontend)
2. Menginstall `ansible` + `sshpass` di VM frontend
3. **Mengenkripsi `secrets.yml`** jika belum terenkripsi
4. Menjalankan Ansible playbook untuk mengkonfigurasi seluruh infrastruktur
5. Menampilkan pesan sukses

> ⏱️ Proses pertama membutuhkan waktu **10–20 menit** tergantung koneksi internet.

### Langkah 4 — Akses Aplikasi
Buka browser dan kunjungi:
```
http://192.168.56.12
```

---

## 🔄 Perintah Vagrant Berguna

```bash
# Jalankan semua VM
vagrant up

# Matikan semua VM
vagrant halt

# Hapus semua VM (mulai dari awal)
vagrant destroy -f

# Re-provision tanpa restart VM
vagrant provision

# Re-provision hanya backend (misal setelah edit playbook)
vagrant provision vm-backend

# SSH ke VM tertentu
vagrant ssh vm-frontend
vagrant ssh vm-backend
vagrant ssh vm-database

# Cek status VM
vagrant status
```

---

## 🐛 Troubleshooting

| Masalah | Kemungkinan Penyebab | Solusi |
|---|---|---|
| `Exec format error: vault_password.txt` | File `.txt` tidak punya shebang | Pastikan baris pertama `#!/bin/sh` |
| `404 NOT_FOUND` dari Gemini | Model tidak tersedia di versi SDK | Pastikan pakai `google-generativeai`, bukan `google-genai` |
| `Decimal is not JSON serializable` | Tipe data MySQL DECIMAL tidak dikonversi | Sudah di-fix via `CustomJSONEncoder` di `app.py` |
| `datetime is not JSON serializable` | Tipe data MySQL DATETIME tidak dikonversi | Sudah di-fix via `CustomJSONEncoder` di `app.py` |
| Riwayat tidak muncul (HTTP 500) | Salah satu error di atas | Cek `sudo journalctl -u bmibackend -n 50` di VM backend |
| `403 API key leaked` | API key bocor ke GitHub | Ganti API key di Google AI Studio, update `secrets.yml` |

---

## 👥 Tim Pengembang

> **Mata Kuliah**: Komunikasi dan Jaringan Komputer — Semester 4  
> **Institusi**: [Nama Institusi]

---

## 📄 Lisensi

Proyek ini dibuat untuk keperluan akademis.
