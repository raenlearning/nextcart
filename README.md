# 🛒 NextCart — Next-Gen Electronics & Computer Mobile Marketplace

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![BLoC](https://img.shields.io/badge/State_Management-BLoC-blue?style=for-the-badge)

**NextCart** adalah aplikasi *e-commerce / marketplace* mobile modern berbasis **Flutter** yang dirancang khusus untuk ritel produk elektronik dan komputer. Aplikasi ini menghadirkan pengalaman belanja yang responsif, aman, dan intuitif bagi pembeli, serta menyediakan dasbor manajemen dan analitik bisnis yang komprehensif untuk admin/penjual.

---

## 🌟 Fitur Utama (Key Features)

### 🛍️ Modul Pembeli 
* **Pencarian & Filter Kategori Interaktif**: Penelusuran produk berbasis kategori (Smartphone, Laptop, Audio, Gaming, dll.) dengan fitur *live search & debounce*.
* **Keamanan Akses Data (Row Level Security)**: Isolasi penuh data riwayat transaksi, profil, dan keranjang belanja berbasis PostgreSQL RLS (`auth.uid()`
* **Alur Checkout & Integrasi Payment Gateway**: Mendukung pemrosesan transaksi *real-time* via **Midtrans Snap WebView**[cite: 3], kalkulasi otomatis PPN (11%) ongkir, serta klaim *voucher* diskon atomik berbasis RPC database
* **Lacak Pengiriman Kurir Interaktif**: Visualisasi peta *real-time* posisi kurir menuju lokasi pembeli menggunakan `flutter_map` dan **Supabase Realtime Broadcast**
* **Manajemen Alamat & Geolocation**: Pemilihan alamat akurat melalui *reverse geocoding* (OpenStreetMap / Nominatim) dan deteksi GPS lokasi pengguna
* **Ulasan & Wishlist**: Fitur pemberian *star rating* & ulasan produk[cite: 3], serta daftar keinginan (*wishlist*)
* **Animasi UI Interaktif**: Efek animasi *cart flying icon*, *bumping badge*, Lottie animation, dan dukungan mode Gelap/Terang (*Dark/Light Mode*)

### 🛡️ Modul Admin & Manajemen 
* **Dasboard Analitik Bisnis**: Grafik performa penjualan (*Revenue Chart*), pendapatan kotor (*Gross Revenue*), total pesanan, produk terlaris (*Top Products*), serta *export* laporan ke CSV
* **Kelola Katalog & Inventaris**: Tambah/edit produk, manajemen stok, unggah multi-foto produk ke **Supabase Storage**, dan fitur otomatis pembersihan berkas (*orphan images cleanup*)
* **Manajemen Pesanan & Status Pengiriman**: Pembaruan status pesanan secara *real-time* (Menunggu Pembayaran ➔ Diproses ➔ Dikirim ➔ Selesai)
* **Manajemen Hak Akses Pengguna**: Fitur *role switching* untuk mengubah peran akun (Admin / Buyer) secara instan

---

## 🏗️ Arsitektur & Tech Stack

* **Frontend Framework**: [Flutter](https://flutter.dev) (Dart)[cite: 3]
* **State Management**: `flutter_bloc` / BLoC Pattern (Auth, Product, Cart, Admin Analytics)
* **Routing**: `go_router`
* **Backend-as-a-Service (BaaS)**: [Supabase](https://supabase.com) (PostgreSQL, Auth, Storage, Edge Functions, Realtime Channels)
* **Payment Gateway**: Midtrans Sandbox & Webhook Integration via Supabase Edge Functions
* **Maps & Geolocation**: `flutter_map` (OpenStreetMap) & `geolocator`

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
Buat berkas .env di direktori root proyek dan masukkan kredensial Supabase Anda:

Cuplikan kode
SUPABASE_URL=[https://your-supabase-project.supabase.co](https://your-supabase-project.supabase.co)
SUPABASE_PUBLISHABLE_KEY=your-supabase-publishable-key
Jalankan Aplikasi:

Bash
flutter run

## 📁 Struktur Proyek (Directory Structure

Aplikasi ini menggunakan pendekatan **Feature-First Architecture**

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


