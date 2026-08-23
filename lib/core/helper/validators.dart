class Validators {
  Validators._();

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _numericRegExp = RegExp(r'^\d+(\.\d{1,2})?$');
  static final RegExp _integerRegExp = RegExp(r'^\d+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    if (!_emailRegExp.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  static String? requiredField(String? value, {String message = 'Wajib diisi'}) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return message;
    return null;
  }

  static String? price(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Harga wajib diisi';
    if (!_numericRegExp.hasMatch(v)) return 'Harga harus angka yang valid';
    if (double.tryParse(v) == null || double.parse(v) <= 0) {
      return 'Harga harus lebih dari 0';
    }
    return null;
  }

  static String? stock(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Stok wajib diisi';
    if (!_integerRegExp.hasMatch(v)) return 'Stok harus bilangan bulat';
    return null;
  }

  static String? weight(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Berat wajib diisi';
    if (!_integerRegExp.hasMatch(v)) return 'Berat harus bilangan bulat';
    if (int.tryParse(v) == null || int.parse(v) <= 0) {
      return 'Berat harus lebih dari 0';
    }
    return null;
  }
}