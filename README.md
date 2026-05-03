# 🌌 AstroEdu - Aplikasi Belajar Astronomi Interaktif

AstroEdu adalah aplikasi mobile pembelajaran astronomi berbasis Flutter yang dirancang untuk membantu pengguna mempelajari planet, rasi bintang, gerhana, galaksi, serta fenomena langit lainnya secara interaktif. Aplikasi ini memanfaatkan sensor GPS, accelerometer, dan kecerdasan buatan (Gemini AI) untuk memberikan pengalaman belajar yang imersif.

## ✨ Fitur Utama

- **Autentikasi Pengguna** – Registrasi, login (email/password), login biometrik (sidik jari/Face ID), dan logout.
- **Halaman Home** – Header profil dengan sapaan, fenomena hari ini (berdasarkan lokasi & zona waktu), grid menu materi, fakta astronomi random, dan card peralatan.
- **Materi Pembelajaran** – Planet (8), Rasi Bintang (6), Gerhana (2), Galaksi (5). Setiap materi memiliki:
  - Sistem unlock progresif (item pertama gratis, berikutnya terbuka setelah membaca)
  - Deskripsi dari Wikipedia API (cache lokal)
  - Progress bar dan badge "Kuis Tersedia"
- **Kuis Per Kategori** – 6 soal pilihan ganda per kategori, skor disimpan ke database.
- **Game "Tangkap Bintang"** – Game berbasis sensor accelerometer. Black hole bergerak sesuai kemiringan HP, target menangkap 20 bintang.
- **AI Chatbot (AstroBot)** – Asisten virtual berbasis Google Gemini AI dengan filter topik astronomi, menyimpan riwayat chat.
- **Peralatan Astronomi** – Daftar alat (teropong, teleskop) dengan konversi mata uang USD/IDR real-time.
- **Profil & Statistik** – Edit nama, email, foto profil; tampilan statistik (jumlah kuis, rata-rata nilai); saran & kesan.
- **Notifikasi Harian** – Pengingat belajar setiap pukul 20.00 (flutter_local_notifications).
- **Fenomena Hari Ini** – Menampilkan informasi fenomena langit terdekat beserta waktu terbaik pengamatan dalam zona waktu lokal (WIB, WITA, WIT, London).
- **Dark Mode** – Tema gelap kosmik yang konsisten di seluruh halaman.

## 🛠️ Teknologi yang Digunakan

| Teknologi | Kegunaan |
|-----------|----------|
| Flutter 3.x & Dart 3.x | Framework utama aplikasi |
| SQLite (sqflite) | Penyimpanan lokal (user, progres, kuis, chat, saran/kesan) |
| Shared Preferences | Menyimpan session login |
| `local_auth` | Autentikasi biometrik (fingerprint/Face ID) |
| `geolocator` & `geocoding` | Mendapatkan posisi GPS dan nama lokasi |
| `sensors_plus` | Akses sensor accelerometer untuk game |
| `google_generative_ai` | Integrasi Google Gemini AI (AstroBot) |
| `http` | Memanggil API Wikipedia, Currency, dan Gemini |
| `flutter_local_notifications` | Notifikasi harian |
| `image_picker` | Memilih foto profil dari galeri |
| `intl` | Format tanggal dan mata uang |

## 📱 Persyaratan Sistem

- **Android** minimal SDK 21 (Android 5.0)
- Diperlukan izin:
  - Lokasi (GPS) – untuk fenomena hari ini
  - Biometrik – untuk login sidik jari/Face ID
  - Notifikasi – untuk pengingat harian
- Sensor accelerometer – untuk game

## 🚀 Cara Menjalankan Proyek

1. **Clone repositori**
   ```bash
   git clone https://github.com/username/astroedu.git
   cd astroedu
2. **Install Dependensi**
   ```bash
   flutter pub get
3. **Siapkan API Key**
   - Buka lib/utils/constants.dart dan ganti nilai geminiApiKey dengan API key Anda dari [Google AI Studio](https://aistudio.google.com/welcome?utm_source=google&utm_medium=cpc&utm_campaign=Cloud-SS-DR-AIS-FY26-global-gsem-1713578&utm_content=text-ad&utm_term=KW_google%20ai%20studio&gad_source=1&gad_campaignid=23417416052&gbraid=0AAAAACn9t64vAWHYGkJxmhedFgB_pswQz&gclid=CjwKCAjw5NvPBhAoEiwA_2egfhWP2nfU1Bh_UHW-B1ZH2bqWIAJd48Q_-EIr7c5KtSJlOLONpKoHGBoCB8oQAvD_BwE)
   ```bash
   static const String geminiApiKey = 'YOUR_API_KEY_HERE';
4. **Jalankan aplikasi**
   ```bash
   flutter run

## 📁 Struktur Folder
```text
lib/
├── main.dart                          # Entry point
├── models/                            # Model data (Planet, Rasi, User, dll)
├── controllers/                       # DataController (Wikipedia cache)
├── services/                          
│   ├── api/                           # API eksternal (Wikipedia, Gemini, Currency)
│   └── local/                         # Layanan lokal (Auth, DB, Lokasi, Notifikasi)
├── utils/                             # Tema, konstanta, helper, timezone
└── views/
    ├── screens/                       # Halaman-halaman aplikasi
    │   ├── auth/                      # Login & Register
    │   ├── home/                      # HomeScreen & MainScreen
    │   ├── planet/                    # List & Detail Planet
    │   ├── rasi/                      # List & Detail Rasi Bintang
    │   ├── gerhana/                   # List & Detail Gerhana
    │   ├── galaksi/                   # List & Detail Galaksi
    │   ├── quiz/                      # Kuis
    │   ├── game/                      # Game Tangkap Bintang
    │   ├── ai/                        # AstroBot (Gemini)
    │   ├── equipment/                 # Peralatan Astronomi
    │   └── profile/                   # Profil & Edit Profil
    └── widgets/                       # Widget reusable (StarBackground, GradientCard)
