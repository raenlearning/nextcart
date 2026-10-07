import 'package:docx_creator/docx_creator.dart';

void main() async {
  final doc = DocxDocumentBuilder();

  // ═══════════════════════════════════════════════════════════════
  // COVER PAGE
  // ═══════════════════════════════════════════════════════════════
  doc
      .h1('NextCart')
      .p('')
      .p('Dokumentasi Teknis Aplikasi E-Commerce')
      .p('')
      .p('Flutter • Supabase • Midtrans')
      .p('')
      .p('')
      .p('Versi: 1.0')
      .p('Tanggal: 1 September 2026')
      .p('')
      .p('Dibangun dengan Flutter 3.44.3')
  // ═══════════════════════════════════════════════════════════════
  // DAFTAR ISI
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('Daftar Isi')
      .numbered([
    'Gambaran Umum',
    'Fitur Aplikasi',
    '   2.1 Fitur Pengguna',
    '   2.2 Fitur Admin',
    'Arsitektur Sistem',
    '   3.1 Tech Stack',
    '   3.2 Arsitektur Layered',
    '   3.3 Diagram Komponen',
    'Skema Database',
    '   4.1 Tabel Utama',
    '   4.2 Diagram Relasi Entity',
    'Alur Kerja (Workflow)',
    '   5.1 Alur Autentikasi',
    '   5.2 Alur Checkout & Pembayaran',
    '   5.3 Alur Push Notification',
    '   5.4 Alur Pembatalan Otomatis',
    'Implementasi Teknis',
    '   6.1 State Management (BLoC)',
    '   6.2 Integrasi Supabase',
    '   6.3 Edge Functions',
    '   6.4 Database Functions & Triggers',
    'Keamanan & Akses',
    'Deployment & Konfigurasi',
  ])
  // ═══════════════════════════════════════════════════════════════
  // BAB 1: GAMBARAN UMUM
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('1. Gambaran Umum')
      .p(
          'NextCart adalah aplikasi e-commerce modern yang dibangun dengan Flutter '
          'menggunakan Supabase sebagai backend. Aplikasi ini dirancang dengan '
          'arsitektur bersih, widget reusable, dan sistem desain yang terinspirasi '
          'dari Apple Store.')
      .p('')
      .h2('1.1 Ringkasan Proyek')
      .table([
    ['Aspek', 'Detail'],
    ['Nama', 'NextCart'],
    ['Versi', '0.1.0+1'],
    ['Platform', 'Android, iOS, Web'],
    ['Backend', 'Supabase (PostgreSQL, Auth, Storage, Edge Functions)'],
    ['State Management', 'flutter_bloc v9.1.1'],
    ['Routing', 'go_router v17.3.0'],
    ['Payment Gateway', 'Midtrans Snap'],
    ['Push Notification', 'Firebase Cloud Messaging'],
    ['Font Utama', 'Geist (Variable)'],
  ])
      .p('')
      .h2('1.2 Fitur Utama')
      .bullet([
    'Autentikasi email/password dan Google OAuth',
    'Katalog produk dengan pencarian dan filter kategori',
    'Keranjang belanja dengan voucher diskon',
    'Integrasi pembayaran Midtrans (Snap WebView)',
    'Riwayat pesanan dengan pelacakan status',
    'Wishlist produk',
    'Ulasan dan rating produk',
    'Push notification real-time',
    'Panel admin lengkap (dashboard, produk, pesanan, pengguna, kategori, voucher, ulasan)',
  ])
  // ═══════════════════════════════════════════════════════════════
  // BAB 2: FITUR APLIKASI
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('2. Fitur Aplikasi')
      .h2('2.1 Fitur Pengguna')
      .h3('2.1.1 Autentikasi')
      .p('Pengguna dapat mendaftar dan masuk menggunakan email/password atau '
          'Google OAuth. Fitur include:')
      .bullet([
    'Registrasi dengan validasi password (minimal 8 karakter)',
    'Indikator kekuatan password (4 level)',
    'Login dengan "Ingat Saya"',
    'Google One-Tap Sign-In',
    'Lupa password via email reset link',
    'Pengecekan status blokir akun setelah login',
  ])
      .p('')
      .h3('2.1.2 Beranda & Katalog')
      .p('Halaman utama menampilkan produk populer dengan kemampuan:')
      .bullet([
    'Pencarian produk dengan debounce 350ms',
    'Filter berdasarkan kategori',
    'Infinite scroll pagination (20 item per halaman)',
    'Sorting: Terbaru, Harga Rendah/Tinggi',
    'Pull-to-refresh',
  ])
      .p('')
      .h3('2.1.3 Detail Produk')
      .p('Halaman detail produk menyediakan:')
      .bullet([
    'Galeri gambar dengan carousel dan indicator',
    'Informasi harga, stok, dan berat',
    'Deskripsi produk',
    'Rating dan jumlah ulasan',
    'Tombol wishlist dengan animasi heart burst',
    'Sharing produk',
    'Kontak WhatsApp ke toko',
    'Sheet spesifikasi produk',
    'Daftar ulasan produk',
    'Pilihan jumlah dan tambah ke keranjang',
  ])
      .p('')
      .h3('2.1.4 Keranjang Belanja')
      .p('Fitur keranjang belanja meliputi:')
      .bullet([
    'Daftar item dengan gambar, nama, harga, dan jumlah',
    'Stepper jumlah (increment/decrement)',
    'Pilihan alamat pengiriman',
    'Pilihan kurir pengiriman',
    'Input kode voucher dengan validasi real-time',
    'Ringkasan harga (subtotal, diskon, ongkir, total)',
    'Tombol checkout',
  ])
      .p('')
      .h3('2.1.5 Checkout & Pembayaran')
      .p('Alur checkout terdiri dari:')
      .numbered([
    'Validasi stok produk ke server',
    'Redeem voucher secara atomik',
    'Kalkulasi diskon dan ongkir',
    'Insert order ke database',
    'Insert order items',
    'Buat record pembayaran Midtrans',
    'Ambil Snap Token via Edge Function',
    'Buka WebView untuk pembayaran',
    'Polling status pesanan',
  ])
      .p('')
      .h3('2.1.6 Riwayat Pesanan')
      .p('Manajemen pesanan dengan:')
      .bullet([
    'Tab status: Aktif, Selesai, Dibatalkan',
    'Pencarian berdasarkan nama produk',
    'Detail pesanan dengan timeline visual',
    'Pelacakan kurir',
    'Countdown pembayaran untuk pesanan pending',
    'Tombol aksi (bayar sekarang)',
  ])
      .p('')
      .h3('2.1.7 Wishlist')
      .p('Fitur wishlist dengan:')
      .bullet([
    'Toggle optimistik (update langsung tanpa reload)',
    'Pencarian dan filter kategori',
    'Sorting: Terbaru, Harga Rendah/Tinggi',
    'Infinite scroll pagination',
    'Pindahkan ke keranjang',
  ])
      .p('')
      .h3('2.1.8 Profil & Alamat')
      .p('Manajemen profil pengguna:')
      .bullet([
    'Edit profil (nama, avatar)',
    'Ubah password',
    'Manajemen alamat pengiriman (CRUD)',
    'Toggle dark mode',
    'Riwayat pesanan aktif, wishlist, dan alamat',
    'Halaman statis (Kebijakan Privasi, Bantuan, Tentang Aplikasi)',
  ])
      .p('')
      .h3('2.1.9 Ulasan & Rating')
      .p('Sistem ulasan produk:')
      .bullet([
    'Lihat semua ulasan untuk produk',
    'Filter berdasarkan rating (1-5 bintang)',
    'Kirim ulasan dengan rating, judul, komentar, dan hingga 3 gambar',
    'Cek apakah sudah mengulas (mencegah duplikat)',
  ])
      .p('')
      .h3('2.1.10 Push Notification')
      .p('Sistem notifikasi:')
      .bullet([
    'In-app notification list',
    'Push notification via Firebase Cloud Messaging',
    'Deep link ke detail pesanan dari notifikasi',
    'Tandai sudah dibaca (per item dan semua)',
  ])
      .p('')
      .h2('2.2 Fitur Admin')
      .h3('2.2.1 Dashboard Analitik')
      .p('Panel admin menyediakan:')
      .bullet([
    'Grafik pendapatan (24 jam, 7 hari, 30 bulan, 6 bulan, 1 tahun)',
    'Jumlah pesanan selesai',
    'Total produk dan pengguna',
    'Alert stok rendah',
    'Top produk',
    'Breakdown status pesanan',
    'Ekspor data ke CSV',
  ])
      .p('')
      .h3('2.2.2 Manajemen Produk')
      .bullet([
    'CRUD produk dengan pencarian dan filter',
    'Upload gambar produk ke Supabase Storage',
    'Filter berdasarkan status (aktif/nonaktif) dan kategori',
    'Validasi stok dan harga',
  ])
      .p('')
      .h3('2.2.3 Manajemen Pesanan')
      .bullet([
    'Lihat semua pesanan dengan pencarian',
    'Filter berdasarkan status',
    'Update status pesanan',
    'Detail pesanan lengkap',
  ])
      .p('')
      .h3('2.2.4 Manajemen Pengguna')
      .bullet([
    'Cari pengguna berdasarkan nama/email',
    'Filter berdasarkan peran',
    'Blokir/buka blokir pengguna',
    'Hapus pengguna secara permanen',
  ])
      .p('')
      .h3('2.2.5 Manajemen Kategori')
      .bullet([
    'Grid 2 kolom dengan kartu kategori',
    'Upload gambar kategori',
    'CRUD kategori',
    'Hitung jumlah produk per kategori',
  ])
      .p('')
      .h3('2.2.6 Manajemen Voucher')
      .bullet([
    'CRUD voucher diskon',
    'Tipe diskon: nominal atau persen',
    'Batas penggunaan',
    'Masa berlaku',
    'Toggle status aktif/nonaktif',
  ])
      .p('')
      .h3('2.2.7 Manajemen Ulasan')
      .bullet([
    'Lihat semua ulasan dengan pencarian',
    'Filter berdasarkan rating dan status balasan',
    'Balas ulasan sebagai admin',
    'Infinite scroll pagination',
  ])
  // ═══════════════════════════════════════════════════════════════
  // BAB 3: ARSITEKTUR SISTEM
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('3. Arsitektur Sistem')
      .h2('3.1 Tech Stack')
      .table([
    ['Komponen', 'Teknologi', 'Versi'],
    ['Framework', 'Flutter', '3.44.3'],
    ['Backend', 'Supabase', '2.15.0'],
    ['Database', 'PostgreSQL', '-'],
    ['State Management', 'flutter_bloc', '9.1.1'],
    ['Routing', 'go_router', '17.3.0'],
    ['Payment', 'Midtrans Snap', '-'],
    ['Push Notification', 'Firebase Cloud Messaging', '16.5.0'],
    ['Maps', 'flutter_map + latlong2', '8.3.1'],
    ['Font', 'Geist (Variable)', '-'],
  ])
      .p('')
      .h2('3.2 Arsitektur Layered')
      .p('NextCart menggunakan arsitektur bersih dengan pemisahan kepedulian yang ketat:')
      .code('''
┌─────────────────────────────────────────────────┐
│                  UI LAYER                       │
│           (Pages / Widgets)                     │
│  • Halaman autentikasi                          │
│  • Katalog produk                               │
│  • Keranjang belanja                            │
│  • Panel admin                                  │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│                 BLOC LAYER                      │
│           (lib/features/*/bloc/)                │
│  • AuthBloc     • ProductBloc    • CartBloc     │
│  • WishlistBloc • AdminProductBloc              │
│  • AdminAnalyticsBloc • ThemeCubit              │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│              REPOSITORY LAYER                   │
│           (lib/data/repository/)                │
│  • AuthRepository      • ProductRepository      │
│  • WishlistRepository  • AddressRepository       │
│  • ReviewRepository    • ShippingRepository      │
│  • AdminRepository     • AdminAnalyticsRepo     │
└─────────────────────┬───────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────┐
│            SUPABASE CLIENT SDK                  │
│  (PostgREST / RPC / Storage / Edge Functions)   │
└─────────────────────────────────────────────────┘
''')
      .p('')
      .h2('3.3 Diagram Komponen')
      .p('Berikut adalah diagram komponen utama aplikasi:')
      .code('''
┌──────────────────────────────────────────────────────────┐
│                     MAIN APP                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐      │
│  │ MultiRepo   │  │ MultiBloc   │  │ GoRouter    │      │
│  │ Provider    │  │ Provider    │  │ (24 routes) │      │
│  └─────────────┘  └─────────────┘  └─────────────┘      │
└──────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
┌───────────────┐  ┌───────────────┐  ┌───────────────┐
│  AUTH SYSTEM  │  │  USER FLOW    │  │  ADMIN FLOW   │
│               │  │               │  │               │
│ • Login       │  │ • Home        │  │ • Dashboard   │
│ • Register    │  │ • Products    │  │ • Products    │
│ • Google OAuth│  │ • Cart        │  │ • Orders      │
│ • Forgot Pass │  │ • Checkout    │  │ • Users       │
│               │  │ • Orders      │  │ • Categories  │
│               │  │ • Wishlist    │  │ • Vouchers    │
│               │  │ • Reviews     │  │ • Reviews     │
│               │  │ • Profile     │  │               │
└───────────────┘  └───────────────┘  └───────────────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           ▼
              ┌────────────────────────┐
              │     SUPABASE           │
              │  ┌──────────────────┐  │
              │  │ PostgreSQL       │  │
              │  │ (14 tables)      │  │
              │  └──────────────────┘  │
              │  ┌──────────────────┐  │
              │  │ Auth             │  │
              │  │ (Email + Google) │  │
              │  └──────────────────┘  │
              │  ┌──────────────────┐  │
              │  │ Storage          │  │
              │  │ (3 buckets)      │  │
              │  └──────────────────┘  │
              │  ┌──────────────────┐  │
              │  │ Edge Functions   │  │
              │  │ (5 functions)    │  │
              │  └──────────────────┘  │
              └────────────────────────┘
''')
  // ═══════════════════════════════════════════════════════════════
  // BAB 4: SKEMA DATABASE
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('4. Skema Database')
      .h2('4.1 Tabel Utama')
      .table([
    ['Tabel', 'Deskripsi', 'Kolom Utama'],
    ['profiles', 'Profil pengguna', 'id, full_name, role, is_blocked'],
    ['products', 'Katalog produk', 'id, name, price, stock, category_id, images'],
    ['categories', 'Kategori produk', 'id, name, image_url, parent_id'],
    ['orders', 'Pesanan', 'id, user_id, total_amount, status, shipping_address'],
    ['order_items', 'Item pesanan', 'id, order_id, product_id, quantity, price_at_purchase'],
    ['payments', 'Pembayaran Midtrans', 'id, order_id, midtrans_id, status, snap_token'],
    ['carts', 'Keranjang', 'id, profile_id'],
    ['cart_items', 'Item keranjang', 'id, cart_id, product_id, quantity'],
    ['wishlist_items', 'Wishlist', 'id, user_id, product_id'],
    ['reviews', 'Ulasan produk', 'id, product_id, user_id, rating, comment'],
    ['vouchers', 'Voucher diskon', 'id, code, discount_type, discount_value, is_active'],
    ['shipping_addresses', 'Alamat pengiriman', 'id, user_id, label, full_address, is_default'],
    ['notifications', 'Notifikasi in-app', 'id, user_id, title, body, type, is_read'],
    ['push_tokens', 'FCM tokens', 'id, user_id, token, platform'],
    ['couriers', 'Kurir pengiriman', 'id, code, name, service, base_cost, per_kg'],
    ['store_settings', 'Pengaturan toko', 'key, value'],
  ])
      .p('')
      .h2('4.2 Diagram Relasi Entity')
      .code('''
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  profiles   │────<│  products   │────<│  categories │
│             │     │             │     │             │
│ id (PK)     │     │ id (PK)     │     │ id (PK)     │
│ full_name   │     │ name        │     │ name        │
│ role        │     │ price       │     │ image_url   │
│ is_blocked  │     │ stock       │     │ parent_id   │
└──────┬──────┘     │ category_id │     └─────────────┘
       │            │ seller_id   │
       │            └─────────────┘
       │
       ├────<┌─────────────┐     ┌─────────────┐
       │     │   orders    │────<│ order_items  │
       │     │             │     │             │
       │     │ id (PK)     │     │ id (PK)     │
       │     │ user_id     │     │ order_id    │
       │     │ total_amount│     │ product_id  │
       │     │ status      │     │ quantity    │
       │     └──────┬──────┘     │ price_at_   │
       │            │            │ purchase    │
       │            │            └─────────────┘
       │            │
       │            ├────<┌─────────────┐
       │            │     │  payments   │
       │            │     │             │
       │            │     │ id (PK)     │
       │            │     │ order_id    │
       │            │     │ midtrans_id │
       │            │     │ status      │
       │            │     │ snap_token  │
       │            │     └─────────────┘
       │            │
       │            ├────<┌─────────────┐
       │            │     │  vouchers   │
       │            │     │             │
       │            │     │ id (PK)     │
       │            │     │ code        │
       │            │     │ discount_   │
       │            │     │ type/value  │
       │            │     └─────────────┘
       │            │
       │            └────<┌──────────────────┐
       │                  │shipping_addresses │
       │                  │                  │
       │                  │ id (PK)          │
       │                  │ user_id          │
       │                  │ label            │
       │                  │ full_address     │
       │                  │ is_default       │
       │                  └──────────────────┘
       │
       ├────<┌─────────────┐
       │     │  wishlist   │
       │     │  _items     │
       │     │             │
       │     │ id (PK)     │
       │     │ user_id     │
       │     │ product_id  │
       │     └─────────────┘
       │
       ├────<┌─────────────┐
       │     │  reviews    │
       │     │             │
       │     │ id (PK)     │
       │     │ product_id  │
       │     │ user_id     │
       │     │ rating      │
       │     └─────────────┘
       │
       ├────<┌─────────────┐
       │     │notifications│
       │     │             │
       │     │ id (PK)     │
       │     │ user_id     │
       │     │ title/body  │
       │     │ is_read     │
       │     └─────────────┘
       │
       └────<┌─────────────┐
             │ push_tokens │
             │             │
             │ id (PK)     │
             │ user_id     │
             │ token       │
             └─────────────┘
''')
  // ═══════════════════════════════════════════════════════════════
  // BAB 5: ALUR KERJA
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('5. Alur Kerja (Workflow)')
      .h2('5.1 Alur Autentikasi')
      .code('''
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  User   │    │  Auth   │    │Supabase │    │ Profile │
│         │    │  BLoC   │    │  Auth   │    │   DB    │
└────┬────┘    └────┬────┘    └────┬────┘    └────┬────┘
     │              │              │              │
     │  Login/Reg   │              │              │
     │─────────────>│              │              │
     │              │              │              │
     │              │  signUp/     │              │
     │              │  signIn     │              │
     │              │─────────────>│              │
     │              │              │              │
     │              │  User/Error  │              │
     │              │<─────────────│              │
     │              │              │              │
     │              │  Check       │              │
     │              │  is_blocked  │              │
     │              │───────────────────────────>│
     │              │              │              │
     │              │  Blocked?    │              │
     │              │<───────────────────────────│
     │              │              │              │
     │  AuthSuccess │              │              │
     │<─────────────│              │              │
     │              │              │              │
     │  Route to    │              │              │
     │  /home       │              │              │
     │─────────────>│              │              │
''')
      .p('')
      .h2('5.2 Alur Checkout & Pembayaran')
      .code('''
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  Cart   │  │  Cart   │  │Supabase │  │Midtrans │  │ Webhook │
│  Page   │  │  BLoC   │  │  DB     │  │ Snap    │  │         │
└────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘
     │            │            │            │            │
     │ Checkout   │            │            │            │
     │───────────>│            │            │            │
     │            │            │            │            │
     │            │ Validate   │            │            │
     │            │ Stock      │            │            │
     │            │───────────>│            │            │
     │            │            │            │            │
     │            │ Redeem     │            │            │
     │            │ Voucher    │            │            │
     │            │ (FOR UPDATE)            │            │
     │            │───────────>│            │            │
     │            │            │            │            │
     │            │ Create     │            │            │
     │            │ Order      │            │            │
     │            │───────────>│            │            │
     │            │            │            │            │
     │            │ Get Snap   │            │            │
     │            │ Token      │            │            │
     │            │─────────────────────────>│            │
     │            │            │            │            │
     │            │ redirect   │            │            │
     │            │ URL        │            │            │
     │            │<─────────────────────────│            │
     │            │            │            │            │
     │ Open       │            │            │            │
     │ WebView    │            │            │            │
     │<───────────│            │            │            │
     │            │            │            │            │
     │ Payment    │            │            │            │
     │ Done       │            │            │            │
     │            │            │            │            │
     │            │            │            │  Payment   │
     │            │            │            │  Callback  │
     │            │            │            │<───────────│
     │            │            │            │            │
     │            │            │  Update    │            │
     │            │            │  Status    │            │
     │            │            │<───────────────────────│
     │            │            │            │            │
     │            │            │  Deduct    │            │
     │            │            │  Stock     │            │
     │            │            │<───────────────────────│
     │            │            │            │            │
     │            │ Poll       │            │            │
     │            │ Status     │            │            │
     │            │───────────>│            │            │
     │            │            │            │            │
     │            │ Verified   │            │            │
     │            │<───────────│            │            │
     │            │            │            │            │
     │ Status     │            │            │            │
     │ Page       │            │            │            │
     │<───────────│            │            │            │
''')
      .p('')
      .h2('5.3 Alur Push Notification')
      .code('''
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│  Admin  │  │Supabase │  │ Database│  │  Edge   │  │   FCM   │
│         │  │  DB     │  │ Webhook │  │Function │  │  Server │
└────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘
     │            │            │            │            │
     │ Update     │            │            │            │
     │ Order      │            │            │            │
     │ Status     │            │            │            │
     │───────────>│            │            │            │
     │            │            │            │            │
     │            │  Trigger   │            │            │
     │            │  (UPDATE)  │            │            │
     │            │───────────>│            │            │
     │            │            │            │            │
     │            │            │  Webhook   │            │
     │            │            │  Payload   │            │
     │            │            │───────────>│            │
     │            │            │            │            │
     │            │            │            │  Get Push  │
     │            │            │            │  Tokens    │
     │            │<───────────────────────────────────│
     │            │            │            │            │
     │            │            │            │  Send      │
     │            │            │            │  Push      │
     │            │            │            │───────────>│
     │            │            │            │            │
     │            │            │            │            │  Deliver
     │            │            │            │            │  to User
     │            │            │            │            │───────>
''')
      .p('')
      .h2('5.4 Alur Pembatalan Otomatis')
      .code('''
┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐
│ pg_cron │  │Supabase │  │  Order  │  │  User   │
│ (5 menit)│  │  DB     │  │  BLoC   │  │         │
└────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘
     │            │            │            │
     │  Execute   │            │            │
     │  cancel_   │            │            │
     │  expired_  │            │            │
     │  orders()  │            │            │
     │───────────>│            │            │
     │            │            │            │
     │            │  Find      │            │
     │            │  orders    │            │
     │            │  > 2 hours │            │
     │            │  status=   │            │
     │            │  waiting_  │            │
     │            │  payment   │            │
     │            │            │            │
     │            │  Update    │            │
     │            │  status -> │            │
     │            │  cancelled │            │
     │            │            │            │
     │            │  Trigger   │            │
     │            │  notif     │            │
     │            │───────────>│            │
     │            │            │  LoadCart  │
     │            │            │───────────>│
''')
  // ═══════════════════════════════════════════════════════════════
  // BAB 6: IMPLEMENTASI TEKNIS
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('6. Implementasi Teknis')
      .h2('6.1 State Management (BLoC)')
      .p('NextCart menggunakan flutter_bloc v9.1.1 untuk state management.')
      .p('')
      .h3('6.1.1 BLoC yang Terdaftar')
      .table([
    ['BLoC', 'Repository', 'Fungsi'],
    ['AuthBloc', 'AuthRepository', 'Login, register, Google OAuth, logout'],
    ['ProductBloc', 'ProductRepository', 'Fetch produk populer, filter kategori, search'],
    ['CartBloc', 'SupabaseClient', 'Keranjang, voucher, checkout, pembayaran'],
    ['WishlistBloc', 'WishlistRepository', 'Toggle wishlist, paginated list'],
    ['AdminProductBloc', 'AdminRepository', 'CRUD produk admin'],
    ['AdminAnalyticsBloc', 'AdminAnalyticsRepo', 'Dashboard analitik'],
    ['ThemeCubit', 'SharedPreferences', 'Toggle dark/light mode'],
  ])
      .p('')
      .h3('6.1.2 Pola State Lifecycle')
      .code('''
Initial → Loading → Loaded
                     ↓
                   Error → (retry) → Loading
                     ↓
              ActionSuccess (untuk operasi CRUD)
''')
      .p('')
      .h2('6.2 Integrasi Supabase')
      .h3('6.2.1 Autentikasi')
      .bullet([
    'Email/Password: signUp() / signInWithPassword()',
    'Google OAuth: signInWithIdToken() dengan idToken dari Google',
    'PKCE auth flow untuk keamanan',
    'Pengecekan is_blocked setelah login',
    'Role-based routing (admin → /admin-dashboard, buyer → /home)',
  ])
      .p('')
      .h3('6.2.2 Storage Buckets')
      .table([
    ['Bucket', 'Tujuan', 'Akses'],
    ['product-images', 'Foto produk', 'Public read, admin write'],
    ['category-images', 'Gambar kategori', 'Public read, admin write'],
    ['review-images', 'Foto ulasan', 'Public read, authenticated insert'],
  ])
      .p('')
      .h3('6.2.3 RPC Functions')
      .table([
    ['Fungsi', 'Dipanggil dari', 'Fungsi'],
    ['get_seller_analytics', 'AdminAnalyticsRepo', 'Data dashboard admin'],
    ['redeem_voucher', 'CartBloc', 'Validasi + klaim voucher atomik'],
    ['get_shipping_rates', 'ShippingRepo', 'Hitung ongkir kurir'],
    ['confirm_order_received', 'Order flow', 'Konfirmasi pesanan diterima'],
    ['cancel_expired_orders', 'pg_cron (5 menit)', 'Batalkan pesanan pending > 2 jam'],
    ['update_product_rating', 'Trigger on reviews', 'Sync rating produk'],
    ['reply_review', 'ReviewRepository', 'Balas ulasan sebagai admin'],
    ['deduct_product_stock', 'midtrans-webhook', 'Potong stok saat pembayaran sukses'],
  ])
      .p('')
      .h2('6.3 Edge Functions')
      .p('Semua edge function menggunakan Deno runtime:')
      .p('')
      .h3('6.3.1 request-payment')
      .p('Membuat sesi pembayaran Midtrans Snap.')
      .bullet([
    'Input: order_id, gross_amount, customer_name, customer_email',
    'Proses: Base64 encode MIDTRANS_SERVER_KEY, POST ke Midtrans API',
    'Output: token (Snap token) dan redirect_url',
    'Secret: MIDTRANS_SERVER_KEY',
  ])
      .p('')
      .h3('6.3.2 midtrans-webhook')
      .p('Menerima notifikasi status pembayaran dari Midtrans.')
      .bullet([
    'Validasi signature menggunakan SHA-512',
    'Mapping status Midtrans ke internal status',
    'Update tabel payments dan orders',
    'Pada settlement: loop order_items, panggil deduct_product_stock',
    'Secret: MIDTRANS_SERVER_KEY, SUPABASE_SERVICE_ROLE_KEY',
  ])
      .p('')
      .h3('6.3.3 order-notify')
      .p('Mengirim push notification saat status pesanan berubah.')
      .bullet([
    'Triggered by Database Webhook pada orders UPDATE',
    'Bandingkan status lama vs baru',
    'Kirim push via FCM HTTP v1',
    'Secret: WEBHOOK_SECRET, FCM_SERVICE_ACCOUNT_JSON',
  ])
      .p('')
      .h3('6.3.4 send-notification')
      .p('Push notification generik yang bisa dipanggil dari client.')
      .bullet([
    'Input: user_id, title, body, data',
    'Proses: Cari push_tokens untuk user, kirim FCM',
    'Secret: FCM_SERVICE_ACCOUNT_JSON',
  ])
      .p('')
      .h3('6.3.5 delete-user')
      .p('Menghapus auth user dari Supabase.')
      .bullet([
    'Input: user_id',
    'Proses: Panggil supabase.auth.admin.deleteUser()',
    'Secret: SUPABASE_SERVICE_ROLE_KEY',
  ])
      .p('')
      .h2('6.4 Database Functions & Triggers')
      .h3('6.4.1 Fungsi Database')
      .table([
    ['Fungsi', 'Keamanan', 'Fungsi'],
    ['redeem_voucher', 'SECURITY DEFINER', 'Validasi + klaim voucher (SELECT FOR UPDATE)'],
    ['deduct_product_stock', 'SECURITY DEFINER', 'Potong stok produk'],
    ['get_seller_analytics', 'SECURITY DEFINER', 'Data analitik dashboard'],
    ['get_shipping_rates', 'SECURITY DEFINER', 'Hitung ongkir'],
    ['confirm_order_received', 'SECURITY DEFINER', 'Konfirmasi pesanan'],
    ['cancel_expired_orders', 'SECURITY DEFINER', 'Batalkan pesanan expired'],
    ['update_product_rating', 'SECURITY DEFINER', 'Sync rating dari reviews'],
    ['reply_review', 'SECURITY DEFINER', 'Balas ulasan admin'],
  ])
      .p('')
      .h3('6.4.2 Trigger Database')
      .table([
    ['Trigger', 'Tabel', 'Event', 'Fungsi'],
    ['review_rating_trigger', 'reviews', 'INSERT/UPDATE/DELETE', 'Sync total_rating & rating_count'],
    ['trg_single_default_address', 'shipping_addresses', 'INSERT/UPDATE', 'Pastikan hanya 1 alamat default'],
    ['trg_order_status_notification', 'orders', 'UPDATE status', 'Buat notifikasi in-app'],
  ])
  // ═══════════════════════════════════════════════════════════════
  // BAB 7: KEAMANAN & AKSES
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('7. Keamanan & Akses')
      .h2('7.1 Role-Based Access Control')
      .p('Akses dikontrol di 3 level:')
      .numbered([
    'Flutter Router Redirect: Cek userMetadata[\'role\'] → admin ke /admin-dashboard, buyer ke /home',
    'RLS Policies: Admin-only tables (profiles, vouchers, categories) cek profiles.role = \'admin\'',
    'Edge Functions: Fungsi seperti reply_review memverifikasi role admin server-side',
  ])
      .p('')
      .h2('7.2 Row Level Security (RLS)')
      .table([
    ['Policy', 'Tabel', 'Aksi', 'Kondisi'],
    ['profiles_admin_update', 'profiles', 'UPDATE', 'admin OR own profile'],
    ['profiles_admin_delete', 'profiles', 'DELETE', 'admin OR own profile'],
    ['vouchers_admin_manage', 'vouchers', 'ALL', 'admin only'],
    ['categories_admin_manage', 'categories', 'ALL', 'admin only'],
  ])
      .p('')
      .h2('7.3 Keamanan Pembayaran')
      .bullet([
    'Webhook signature verification (SHA-512)',
    'Server-side voucher redemption (SELECT FOR UPDATE)',
    'Stock deduction hanya pada settlement (bukan checkout)',
    'Polling status sebagai fallback',
  ])
      .p('')
      .h2('7.4 Autentikasi')
      .bullet([
    'PKCE auth flow untuk keamanan OAuth',
    'Session-based authentication via Supabase',
    'FCM token management (register on login, delete on logout)',
    'Pengecekan is_blocked setelah login',
  ])
  // ═══════════════════════════════════════════════════════════════
  // BAB 8: DEPLOYMENT & KONFIGURASI
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('8. Deployment & Konfigurasi')
      .h2('8.1 Environment Variables')
      .p('File .env harus berisi:')
      .code('''
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_PUBLISHABLE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
MIDTRANS_SERVER_KEY=your-midtrans-server-key
MIDTRANS_CLIENT_KEY=your-midtrans-client-key
FCM_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
''')
      .p('')
      .h2('8.2 Supabase Setup')
      .numbered([
    'Buat project di Supabase',
    'Jalankan semua migration files di supabase/migrations/',
    'Deploy edge functions: supabase functions deploy',
    'Setup storage buckets: product-images, category-images, review-images',
    'Setup pg_cron untuk cancel_expired_orders',
    'Setup Database Webhooks untuk order-notify',
  ])
      .p('')
      .h2('8.3 Firebase Setup')
      .numbered([
    'Buat project di Firebase Console',
    'Download google-services.json (Android) / GoogleService-Info.plist (iOS)',
    'Setup FCM Server Key sebagai secret di Supabase',
    'Configure Firebase Cloud Messaging',
  ])
      .p('')
      .h2('8.4 Midtrans Setup')
      .numbered([
    'Daftar di Midtrans Dashboard',
    'Get Server Key dan Client Key',
    'Setup Webhook URL ke supabase/functions/midtrans-webhook',
    'Enable Snap payment method',
    'Test dengan sandbox environment',
  ])
      .p('')
      .h2('8.5 Build & Deploy')
      .code('''
# Install dependencies
flutter pub get

# Generate launcher icons
flutter pub run icons_launcher:create

# Build APK (debug)
flutter build apk --debug

# Build APK (release)
flutter build apk --release

# Build IPA (iOS)
flutter build ipa

# Deploy edge functions
supabase functions deploy

# Run migrations
supabase db push
''')
      .p('')
      .h2('8.6 Arsitektur Deployment')
      .code('''
┌─────────────────────────────────────────────────────────┐
│                    DEPLOYMENT                           │
│                                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │
│  │   Flutter   │  │  Supabase   │  │  Firebase   │     │
│  │   App       │  │  Backend    │  │  Cloud      │     │
│  │             │  │             │  │  Messaging  │     │
│  │ • Android   │  │ • PostgreSQL│  │             │     │
│  │ • iOS       │  │ • Auth      │  │ • FCM       │     │
│  │ • Web       │  │ • Storage   │  │ • Analytics │     │
│  │             │  │ • Edge Fn   │  │             │     │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │
│         │                │                │             │
│         └────────────────┼────────────────┘             │
│                          │                              │
│                    ┌─────┴─────┐                        │
│                    │  Midtrans │                        │
│                    │  Payment  │                        │
│                    │  Gateway  │                        │
│                    └───────────┘                        │
└─────────────────────────────────────────────────────────┘
''')
  // ═══════════════════════════════════════════════════════════════
  // PENUTUP
  // ═══════════════════════════════════════════════════════════════
  ..pageBreak()
      .h1('Penutup')
      .p('Dokumentasi ini memberikan gambaran lengkap tentang arsitektur, '
          'fitur, dan implementasi teknis aplikasi NextCart.')
      .p('')
      .p('Untuk pertanyaan atau dukungan teknis, silakan hubungi tim pengembang.')
      .p('')
      .p('─' * 50)
      .p('NextCart Technical Documentation v1.0')
      .p('Generated on September 1, 2026');

  // Build and save
  final builtDoc = doc.build();
  await DocxExporter().exportToFile(builtDoc, 'docs/NextCart_Dokumentasi_Teknis.docx');

  print('✅ Dokumen berhasil dibuat: docs/NextCart_Dokumentasi_Teknis.docx');
}
