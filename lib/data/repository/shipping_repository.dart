import 'package:supabase_flutter/supabase_flutter.dart';

class ShippingRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Menghitung tarif ongkir semua kurir aktif untuk alamat tujuan.
  Future<List<Map<String, dynamic>>> fetchRates({
    required String? destPostal,
    String? destCity,
    required int weightGrams,
  }) async {
    final data = await _supabase.rpc('get_shipping_rates', params: {
      'p_dest_postal': destPostal ?? '',
      'p_dest_city': destCity ?? '',
      'p_weight_grams': weightGrams,
    });

    final Map result = Map.from(data as Map);
    final List rates = (result['rates'] as List?) ?? const [];
    return rates
        .map((r) => Map<String, dynamic>.from(r as Map))
        .toList();
  }
}
