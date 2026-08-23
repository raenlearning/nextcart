import 'package:flutter_test/flutter_test.dart';
import 'package:nextcart/core/helper/validators.dart';

void main() {
  group('Validators.email', () {
    test('menerima email yang valid', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('a@b.c'), isNull);
      expect(Validators.email('nama.belakang+tag@sub.domain.co.id'), isNull);
    });

    test('menolak email kosong', () {
      expect(Validators.email(''), 'Email wajib diisi');
      expect(Validators.email(null), 'Email wajib diisi');
      expect(Validators.email('   '), 'Email wajib diisi');
    });

    test('menolak format email tidak valid', () {
      expect(Validators.email('a@b'), 'Format email tidak valid');
      expect(Validators.email('a@@b.com'), 'Format email tidak valid');
      expect(Validators.email('@gmail.com'), 'Format email tidak valid');
      expect(Validators.email('user.gmail.com'), 'Format email tidak valid');
      expect(Validators.email('user@'), 'Format email tidak valid');
      expect(Validators.email('user @gmail.com'), 'Format email tidak valid');
    });
  });

  group('Validators.requiredField', () {
    test('menolak kosong dan menerima isi', () {
      expect(Validators.requiredField(''), 'Wajib diisi');
      expect(Validators.requiredField(null), 'Wajib diisi');
      expect(Validators.requiredField('  '), 'Wajib diisi');
      expect(Validators.requiredField('Produk A'), isNull);
    });

    test('memakai pesan kustom', () {
      expect(
        Validators.requiredField('', message: 'Nama wajib diisi'),
        'Nama wajib diisi',
      );
    });
  });

  group('Validators.price', () {
    test('menerima harga valid', () {
      expect(Validators.price('1000'), isNull);
      expect(Validators.price('0.5'), isNull);
      expect(Validators.price('14999.99'), isNull);
    });

    test('menolak harga kosong / non-angka / <= 0', () {
      expect(Validators.price(''), 'Harga wajib diisi');
      expect(Validators.price(null), 'Harga wajib diisi');
      expect(Validators.price('abc'), 'Harga harus angka yang valid');
      expect(Validators.price('12,5'), 'Harga harus angka yang valid');
      expect(Validators.price('0'), 'Harga harus lebih dari 0');
      expect(Validators.price('-5'), 'Harga harus angka yang valid');
    });
  });

  group('Validators.stock', () {
    test('menerima stok integer non-negatif', () {
      expect(Validators.stock('0'), isNull);
      expect(Validators.stock('150'), isNull);
    });

    test('menolak stok kosong / bukan integer / negatif', () {
      expect(Validators.stock(''), 'Stok wajib diisi');
      expect(Validators.stock(null), 'Stok wajib diisi');
      expect(Validators.stock('1.5'), 'Stok harus bilangan bulat');
      expect(Validators.stock('abc'), 'Stok harus bilangan bulat');
      expect(Validators.stock('-3'), 'Stok harus bilangan bulat');
    });
  });

  group('Validators.weight', () {
    test('menerima berat integer positif', () {
      expect(Validators.weight('250'), isNull);
      expect(Validators.weight('1'), isNull);
    });

    test('menolak berat kosong / bukan integer / <= 0', () {
      expect(Validators.weight(''), 'Berat wajib diisi');
      expect(Validators.weight(null), 'Berat wajib diisi');
      expect(Validators.weight('abc'), 'Berat harus bilangan bulat');
      expect(Validators.weight('0'), 'Berat harus lebih dari 0');
      expect(Validators.weight('-1'), 'Berat harus bilangan bulat');
    });
  });
}