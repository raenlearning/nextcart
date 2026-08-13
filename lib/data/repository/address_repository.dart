import 'package:supabase_flutter/supabase_flutter.dart';

class ShippingAddress {
  final String id;
  final String? label;
  final String? recipientName;
  final String? phone;
  final String fullAddress;
  final String? province;
  final String? city;
  final String? district;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  ShippingAddress({
    required this.id,
    this.label,
    this.recipientName,
    this.phone,
    required this.fullAddress,
    this.province,
    this.city,
    this.district,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      id: json['id'] as String,
      label: json['label'] as String?,
      recipientName: json['recipient_name'] as String?,
      phone: json['phone'] as String?,
      fullAddress: json['full_address'] as String,
      province: json['province'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      postalCode: json['postal_code'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}

class AddressRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ShippingAddress>> fetchAddresses() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _supabase
        .from('shipping_addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => ShippingAddress.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createAddress(Map<String, dynamic> fields) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      await _supabase
          .from('shipping_addresses')
          .insert({...fields, 'user_id': userId});
    }
  }

  Future<void> updateAddress(String id, Map<String, dynamic> fields) async {
    await _supabase
        .from('shipping_addresses')
        .update({...fields, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<void> deleteAddress(String id) async {
    await _supabase.from('shipping_addresses').delete().eq('id', id);
  }
}