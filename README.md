# BMI Tracker

Aplikasi web kalkulator BMI (Body Mass Index) yang bisa menghitung, menyimpan riwayat, dan memberikan rekomendasi kesehatan lewat AI. Mendukung dua metode perhitungan: standar WHO/CDC untuk dewasa (≥ 20 tahun) dan persentil CDC untuk anak & remaja (2–19 tahun). Seluruh infrastruktur berjalan di atas 3 Virtual Machine yang di-provision otomatis pakai Vagrant dan Ansible.

---

## Arsitektur Sistem

Sistem ini dibagi ke dalam 3 VM yang saling terhubung lewat jaringan private `192.168.56.0/24`:

```
                    HOST MACHINE
                         |
        -----------------+-----------------
        |                |                |
   VM Database      VM Backend       VM Frontend
  192.168.56.11    192.168.56.10    192.168.56.12
    MySQL 8.0      Python Flask        Nginx
    port 3306       port 5000         port 80
```

Alur kerjanya sederhana: user buka browser ke `http://192.168.56.12`, request diterima Nginx di VM Frontend, lalu diteruskan ke Flask API di VM Backend. Backend yang ngurus logika perhitungan dan komunikasi ke MySQL di VM Database buat nyimpen/ambil data. Fitur chat AI juga dihandle backend lewat Google Gemini API.

VM Frontend sekaligus jadi Ansible Control Node — dia yang nge-provision kedua VM lainnya waktu `vagrant up`.

---

## Pembagian Fungsi VM

### VM Database (`192.168.56.11`)

Khusus untuk nyimpen data. Di dalamnya jalan MySQL 8.0 dengan database `db_bmi` dan tabel `riwayat_bmi`. MySQL di-bind ke `0.0.0.0` supaya bisa diakses dari VM lain. User MySQL yang dipakai: `user_bmi`.

Struktur tabelnya:

| Kolom    | Tipe           |
|----------|----------------|
| id       | INT (PK, AI)   |
| nama     | VARCHAR(255)    |
| umur     | INT             |
| berat    | DECIMAL(5,2)    |
| tinggi   | DECIMAL(5,2)    |
| bmi      | DECIMAL(5,2)    |
| kategori | VARCHAR(100)    |
| tanggal  | DATETIME        |

### VM Backend (`192.168.56.10`)

Jalan di port 5000, pakai Flask sebagai REST API. Endpoint yang tersedia:

| Method | Endpoint    | Fungsi                         |
|--------|-------------|--------------------------------|
| POST   | `/api/bmi`  | Hitung BMI dan simpan ke DB    |
| GET    | `/api/bmi`  | Ambil semua riwayat dari DB    |
| POST   | `/api/chat` | Kirim pesan ke Gemini AI       |

Logika perhitungan BMI:
- Umur ≥ 20 → pakai standar WHO/CDC (Kurus / Normal / Gemuk / Obesitas)
- Umur < 20 → pakai persentil CDC (berdasarkan ambang batas BMI yang disederhanakan)

Backend juga handle konversi tipe data MySQL (Decimal, datetime) supaya bisa di-serialize ke JSON tanpa error.

### VM Frontend (`192.168.56.12`)

Nginx serve file `index.html` di port 80. Halaman ini berisi:
- Form kalkulator BMI (nama, umur, berat, tinggi)
- Tampilan hasil BMI dengan warna sesuai kategori
- Tabel referensi BMI untuk dewasa dan anak
- Riwayat perhitungan (fetch real-time dari backend)
- Chat AI buat konsultasi gizi (pakai Gemini)

Frontend murni HTML + CSS + JavaScript vanilla, tanpa framework tambahan. Font pakai Plus Jakarta Sans dari Google Fonts.

---

## Tools & Teknologi

| Komponen       | Teknologi                                              |
|----------------|--------------------------------------------------------|
| Virtualisasi   | VirtualBox                                             |
| Manajemen VM   | Vagrant                                                |
| Provisioning   | Ansible (jalan dari dalam VM Frontend)                 |
| Secret Mgmt    | Ansible Vault (AES-256, buat enkripsi API key Gemini)  |
| Database       | MySQL 8.0                                              |
| Backend        | Python 3, Flask, Flask-CORS, mysql-connector-python    |
| AI             | Google Gemini 2.5 Flash (`google-generativeai`)        |
| Frontend       | HTML5, CSS3, JavaScript ES6+                           |
| Web Server     | Nginx                                                  |
| OS (semua VM)  | Ubuntu 22.04 LTS (bento/ubuntu-22.04)                  |

---

## Cara Instalasi & Menjalankan

### Prasyarat

- VirtualBox (≥ 6.1)
- Vagrant (≥ 2.3)
- Git
- RAM minimal 8 GB (3 VM masing-masing 2 GB + overhead)

### Langkah-langkah

**1. Clone repo**

```bash
git clone https://github.com/Gu4rdians/tubesccsemester4.git
cd tubesccsemester4
```

**2. Buat file `vault_password.txt`**

File ini tidak ikut di-push ke repo (masuk `.gitignore`). Harus dibuat manual:

```bash
cat > ansible/vault_password.txt << 'EOF'
#!/bin/sh
printf '%s' 'rahasia_vault_bmi_2026'
EOF
```

File ini bentuknya shell script karena VirtualBox shared folder otomatis kasih executable bit ke semua file dari Windows, dan Ansible baca file executable sebagai script.

**3. Jalankan Vagrant**

```bash
vagrant up
```

Proses ini bakal:
1. Bikin 3 VM sekaligus (database → backend → frontend)
2. Install Ansible dan sshpass di VM Frontend
3. Enkripsi `secrets.yml` kalau belum terenkripsi
4. Jalankan playbook Ansible buat setup semua VM
5. Tampilkan pesan kalau deployment sukses

Pertama kali jalan butuh sekitar 10–20 menit tergantung koneksi internet.

**4. Buka aplikasi**

Akses di browser:

```
http://192.168.56.12
```

### Perintah Vagrant yang sering dipakai

```bash
vagrant halt              # matikan semua VM
vagrant destroy -f        # hapus semua VM
vagrant provision         # jalankan ulang provisioning
vagrant ssh vm-frontend   # masuk ke VM frontend
vagrant ssh vm-backend    # masuk ke VM backend
vagrant ssh vm-database   # masuk ke VM database
```
