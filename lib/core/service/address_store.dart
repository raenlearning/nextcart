import 'package:flutter/foundation.dart';
import 'package:nextcart/data/repository/address_repository.dart';

class AddressStore extends ValueNotifier<ShippingAddress?> {
  AddressStore._() : super(null);

  static final AddressStore instance = AddressStore._();

  final AddressRepository _repository = AddressRepository();

  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> load() async {
    try {
      final selected = await _repository.fetchSelectedAddress();
      _loaded = true;
      if (selected != null) value = selected;
    } catch (_) {
      _loaded = true;
    }
  }

  Future<void> refresh() => load();

  Future<void> select(ShippingAddress address) async {
    value = address;
    try {
      await _repository.selectAddress(address.id);
    } catch (_) {}
  }

  Future<void> clear() async {
    value = null;
    try {
      await _repository.selectAddress(null);
    } catch (_) {}
  }
}