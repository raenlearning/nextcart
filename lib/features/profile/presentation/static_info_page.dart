import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

enum StaticInfoType { privacyPolicy, helpCenter, aboutApp }

class StaticInfoPage extends StatelessWidget {
  final StaticInfoType type;

  const StaticInfoPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final (title, sections) = _content(type);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final section in sections) ...[
            Text(
              section.heading,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            for (final paragraph in section.paragraphs) ...[
              Text(
                paragraph,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  (String, List<_InfoSection>) _content(StaticInfoType type) {
    switch (type) {
      case StaticInfoType.privacyPolicy:
        return ('Kebijakan Privasi', const [
          _InfoSection(
            heading: 'Data yang Kami Kumpulkan',
            paragraphs: [
              'Kami mengumpulkan data yang Anda berikan saat mendaftar, seperti nama, '
                  'email, alamat pengiriman, dan nomor telepon. Data ini digunakan untuk '
                  'memproses pesanan dan memberikan layanan yang lebih baik.',
            ],
          ),
          _InfoSection(
            heading: 'Penggunaan Data',
            paragraphs: [
              'Data Anda digunakan untuk memproses transaksi, mengirim notifikasi pesanan, '
                  'dan meningkatkan pengalaman berbelanja Anda. Kami tidak menjual data '
                  'pribadi Anda kepada pihak ketiga.',
            ],
          ),
          _InfoSection(
            heading: 'Keamanan Data',
            paragraphs: [
              'Kami melindungi data Anda dengan enkripsi dan kebijakan keamanan yang ketat. '
                  'Akses ke data hanya diberikan kepada pihak yang membutuhkannya untuk '
                  'kebutuhan operasional.',
            ],
          ),
          _InfoSection(
            heading: 'Hak Anda',
            paragraphs: [
              'Anda dapat mengakses, mengubah, atau menghapus data pribadi Anda kapan saja '
                  'melalui halaman pengaturan akun. Anda juga dapat menghubungi kami jika '
                  'memiliki pertanyaan tentang kebijakan privasi ini.',
            ],
          ),
        ]);
      case StaticInfoType.helpCenter:
        return ('Pusat Bantuan', const [
          _InfoSection(
            heading: 'Cara Berbelanja',
            paragraphs: [
              'Pilih produk yang Anda inginkan, tambahkan ke keranjang, lalu lanjutkan ke '
                  'pembayaran. Anda akan diarahkan ke halaman pembayaran untuk menyelesaikan '
                  'transaksi.',
            ],
          ),
          _InfoSection(
            heading: 'Pembayaran',
            paragraphs: [
              'Kami menerima berbagai metode pembayaran melalui gateway pembayaran. '
                  'Setelah pembayaran berhasil, status pesanan akan diperbarui secara otomatis.',
            ],
          ),
          _InfoSection(
            heading: 'Pengiriman',
            paragraphs: [
              'Pesanan akan diproses dan dikirim sesuai dengan kurir yang Anda pilih saat '
                  'checkout. Anda dapat melacak pesanan melalui menu Pesanan.',
            ],
          ),
          _InfoSection(
            heading: 'Hubungi Kami',
            paragraphs: [
              'Jika Anda membutuhkan bantuan, silakan hubungi tim dukungan kami melalui '
                  'email dukungan@nextcart.app atau melalui menu notifikasi.',
            ],
          ),
        ]);
      case StaticInfoType.aboutApp:
        return ('Tentang Aplikasi', const [
          _InfoSection(
            heading: 'NextCart',
            paragraphs: [
              'NextCart adalah aplikasi belanja yang dirancang untuk memberikan pengalaman '
                  'belanja online yang mudah, aman, dan menyenangkan.',
            ],
          ),
          _InfoSection(
            heading: 'Fitur Utama',
            paragraphs: [
              'Katalog produk, keranjang belanja, checkout dengan pembayaran online, '
                  'pelacakan pesanan, ulasan produk, dan notifikasi pembaruan pesanan.',
            ],
          ),
          _InfoSection(
            heading: 'Versi',
            paragraphs: [
              'Versi 0.1.0',
            ],
          ),
        ]);
    }
  }
}

class _InfoSection {
  final String heading;
  final List<String> paragraphs;

  const _InfoSection({required this.heading, required this.paragraphs});
}