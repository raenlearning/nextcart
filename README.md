# 🛒 NextCart — Next-Gen Electronics & Computer Mobile Marketplace

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![BLoC](https://img.shields.io/badge/State_Management-BLoC-blue?style=for-the-badge)

**NextCart** adalah aplikasi *e-commerce / marketplace* mobile modern berbasis **Flutter** yang dirancang khusus untuk ritel produk elektronik dan komputer. Aplikasi ini menghadirkan pengalaman belanja yang responsif, aman, dan intuitif bagi pembeli, serta menyediakan dasbor manajemen dan analitik bisnis yang komprehensif untuk admin/penjual.

---

## 🌟 Fitur Utama (Key Features)

### 🛍️ Modul Pembeli (Buyer Experience)
* **Pencarian & Filter Kategori Interaktif**: Penelusuran produk berbasis kategori (Smartphone, Laptop, Audio, Gaming, dll.) dengan fitur *live search & debounce*[cite: 3].
* **Keamanan Akses Data (Row Level Security)**: Isolasi penuh data riwayat transaksi, profil, dan keranjang belanja berbasis PostgreSQL RLS (`auth.uid()`)[cite: 3].
* **Alur Checkout & Integrasi Payment Gateway**: Mendukung pemrosesan transaksi *real-time* via **Midtrans Snap WebView**[cite: 3], kalkulasi otomatis PPN (11%)[cite: 3], ongkir, serta klaim *voucher* diskon atomik berbasis RPC database[cite: 3].
* **Lacak Pengiriman Kurir Interaktif**: Visualisasi peta *real-time* posisi kurir menuju lokasi pembeli menggunakan `flutter_map` dan **Supabase Realtime Broadcast**[cite: 3].
* **Manajemen Alamat & Geolocation**: Pemilihan alamat akurat melalui *reverse geocoding* (OpenStreetMap / Nominatim) dan deteksi GPS lokasi pengguna[cite: 3].
* **Ulasan & Wishlist**: Fitur pemberian *star rating* & ulasan produk[cite: 3], serta daftar keinginan (*wishlist*)[cite: 3].
* **Animasi UI Interaktif**: Efek animasi *cart flying icon*, *bumping badge*, Lottie animation, dan dukungan mode Gelap/Terang (*Dark/Light Mode*)[cite: 3].

### 🛡️ Modul Admin & Manajemen (Admin & Seller Portal)
* **Dasboard Analitik Bisnis**: Grafik performa penjualan (*Revenue Chart*), pendapatan kotor (*Gross Revenue*), total pesanan, produk terlaris (*Top Products*), serta *export* laporan ke CSV[cite: 3].
* **Kelola Katalog & Inventaris**: Tambah/edit produk, manajemen stok, unggah multi-foto produk ke **Supabase Storage**, dan fitur otomatis pembersihan berkas (*orphan images cleanup*)[cite: 3].
* **Manajemen Pesanan & Status Pengiriman**: Pembaruan status pesanan secara *real-time* (Menunggu Pembayaran ➔ Diproses ➔ Dikirim ➔ Selesai)[cite: 3].
* **Manajemen Hak Akses Pengguna**: Fitur *role switching* untuk mengubah peran akun (Admin / Buyer) secara instan[cite: 3].

---

## 🏗️ Arsitektur & Tech Stack

* **Frontend Framework**: [Flutter](https://flutter.dev) (Dart)[cite: 3]
* **State Management**: `flutter_bloc` / BLoC Pattern (Auth, Product, Cart, Admin Analytics)[cite: 3]
* **Routing**: `go_router`[cite: 3]
* **Backend-as-a-Service (BaaS)**: [Supabase](https://supabase.com) (PostgreSQL, Auth, Storage, Edge Functions, Realtime Channels)[cite: 3]
* **Payment Gateway**: Midtrans Sandbox & Webhook Integration via Supabase Edge Functions[cite: 3]
* **Maps & Geolocation**: `flutter_map` (OpenStreetMap) & `geolocator`[cite: 3]

---

🚀 Panduan Memulai (Getting Started)
Prasyarat
Flutter SDK (v3.x atau terbaru)

akun Supabase & Proyek Active

Akun Midtrans Sandbox (Merchant)

Langkah Instalasi
Clone Repositori:

Bash
git clone [https://github.com/username/nextcart.git](https://github.com/username/nextcart.git)
cd nextcart
Instal Dependensi:

Bash
flutter pub get
Konfigurasi Environment (.env):
Buat berkas .env di direktori akar (root) proyek dan masukkan kredensial Supabase Anda[cite: 3]:

Cuplikan kode
SUPABASE_URL=[https://your-supabase-project.supabase.co](https://your-supabase-project.supabase.co)
SUPABASE_PUBLISHABLE_KEY=your-supabase-publishable-key
Jalankan Aplikasi:

Bash
flutter run

## 📁 Struktur Proyek (Directory Structure

Aplikasi ini menggunakan pendekatan **Feature-First Architecture**[cite: 3]:

```text
lib/
├── core/                   # Utility, Theme, Router, & Shared Widgets
│   ├── constants/          # Assets, Colors, & Order Status Constants
│   ├── helper/             # Currency Formatter, CSV Exporter, Animations
│   ├── router/             # GoRouter Navigation Config
│   └── theme/              # Light & Dark App Themes
├── data/                   # Data Layer
│   ├── models/             # Product, Category, Review, Analytics Models
│   └── repository/         # Supabase Repositories (Auth, Product, Order, etc.)
└── features/               # Presentation & Business Logic (BLoC) Layer
    ├── admin/              # Dashboard, Product/Order/User Management
    ├── address/            # Address List & Form
    ├── auth/               # Login & Register BLoCs & Screens
    ├── cart/               # Cart BLoC, Checkout, & Payment WebView
    ├── home/               # Home View & Bottom Navigation Shell
    ├── location/           # OpenStreetMap Address Picker
    ├── notification/       # Notification List & Push Handler
    ├── onboarding/         # Onboarding Slides
    ├── order/              # Order History, Details, & Courier Tracking Map
    ├── product/            # Product Details, Reviews, & Grid View
    ├── profile/            # Profile Detail & Settings
    └── wishlist/           # User Wishlist Grid


