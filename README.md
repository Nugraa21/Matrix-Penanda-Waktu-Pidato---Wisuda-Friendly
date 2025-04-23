# 🎓 N21-Pidato Timer - Matrix Waktu untuk Wisuda 🎓

Proyek ini dirancang sebagai alat bantu visual selama acara **wisuda**, terutama saat **pidato**. Dengan menggunakan **ESP32** dan **dot matrix LED display**, alat ini akan menampilkan **countdown waktu bicara**, serta memberikan **peringatan visual otomatis** saat waktu hampir habis. 

Dibandingkan dengan mengangkat papan atau memberi isyarat manual, alat ini memberikan cara yang **lebih elegan, tenang, dan efektif** untuk mengingatkan pembicara mengenai waktu yang tersisa.

---

# 📱 Aplikasi Matrix Remote Control

Aplikasi ini memungkinkan pengguna untuk mengendalikan proyek **dot matrix** secara jarak jauh menggunakan **MQTT**. Pengguna dapat mengonfigurasi berbagai pengaturan seperti broker MQTT, port, topik, dan client ID. Aplikasi ini juga memungkinkan pengguna untuk memulai countdown dan mengirim pesan ke topik MQTT yang telah ditentukan untuk mengendalikan tampilan waktu pada dot matrix.

## ✨ Fitur Utama

- **Pengendalian Matriks LED**: Kirim pesan ke proyek dot matrix menggunakan MQTT.
- **Pengaturan MQTT**: Atur broker MQTT, port, topik, dan client ID sesuai kebutuhan.
- **Countdown Timer**: Mulai countdown yang akan mengontrol proyek dot matrix.
- **Log Pengiriman**: Lihat histori pengiriman pesan ke MQTT.
- **Mode Gelap/Terang**: Pilih antara mode gelap dan terang sesuai preferensi.
- **Notifikasi Waktu**: Kirim pesan ke topik MQTT setiap beberapa detik selama countdown, memberikan peringatan waktu.

## 🚀 Instalasi

Untuk menjalankan aplikasi ini, Anda memerlukan:

- **Flutter SDK**: Pastikan Flutter sudah terinstal di sistem Anda. Jika belum, ikuti petunjuk instalasi [Flutter SDK](https://flutter.dev/docs/get-started/install).
- **MQTT Broker**: Aplikasi ini terhubung ke broker MQTT seperti `broker.emqx.io`, namun Anda bisa menggantinya dengan broker lain sesuai kebutuhan.

Ikuti langkah-langkah berikut untuk menjalankan aplikasi ini:

1. Clone repositori ini:
   ```bash
   git clone https://github.com/username/repo-name.git
   cd repo-name
    ```
## Install dependensi dengan:

```
flutter pub get
```
Jalankan aplikasi dengan:

```
flutter run
```

# 🎯 Tujuan Proyek
Proyek ini bertujuan untuk membantu panitia wisuda atau pembawa acara dalam:

- Mengingatkan pembicara mengenai waktu pidato yang tersisa.

- Memberikan peringatan otomatis saat waktu hampir habis (2 menit & 1 menit).

- Menghindari interupsi manual seperti angkat papan atau bisikan yang dapat mengganggu acara.

# 🧰 Teknologi yang Digunakan
> ESP32: Modul WiFi untuk kontrol logika dan koneksi ke WiFi.

>MD_Parola & MD_MAX72XX: Library untuk mengontrol tampilan LED Matrix.

>WiFiManager: Memudahkan pengaturan koneksi WiFi melalui HP.

>PubSubClient: Digunakan untuk komunikasi dengan broker MQTT.

>NTP (time.h): Sinkronisasi waktu melalui internet untuk memastikan waktu yang tepat.

# 🚀 Cara Menggunakan
>Upload kode ke ESP32.

>Sambungkan ke hotspot N21-Matrix (password: 12345678).

>Pilih WiFi yang tersedia melalui browser.

>Gunakan aplikasi MQTT (contoh: MQTT Explorer) untuk mengirim pesan:

>Topik: matrix/text

>Pesan: mulai

>Matrix akan mulai countdown selama 5 menit secara otomatis.

<!-- # 📷 Demo Proyek
(Foto alat digunakan di wisuda atau saat testing bisa ditambahkan di sini) -->

# 📥 Library yang Dibutuhkan
- WiFiManager by tzapu

- PubSubClient by Nick O'Leary

- MD_Parola & MD_MAX72XX by MajicDesigns

# 👨‍💻 Pengembang
Ludang Prasetyo Nugroho
Mahasiswa Teknik Komputer – UTDI
#### 📍 Yogyakarta, Indonesia

## 💡 Catatan Tambahan
```
Countdown dapat diubah dari 5 menit ke durasi lain sesuai kebutuhan.

Waktu real-time disinkronkan dengan zona waktu GMT+7 (WIB).

Proyek ini adalah bagian dari tugas kampus dan dirancang khusus untuk acara wisuda UTDI.

Terima kasih telah mengunjungi proyek ini! Jika ada pertanyaan atau saran, jangan ragu untuk menghubungi saya.

```

Ini adalah seluruh isi file `README.md` yang lengkap. Semoga membantu untuk membuat proyekmu lebih terstruktur dan informatif!