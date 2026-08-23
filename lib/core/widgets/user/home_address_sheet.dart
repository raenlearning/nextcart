import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/service/address_store.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/address_repository.dart';

class HomeAddressSheet extends StatefulWidget {
  const HomeAddressSheet({super.key});

  @override
  State<HomeAddressSheet> createState() => _HomeAddressSheetState();
}

class _HomeAddressSheetState extends State<HomeAddressSheet> {
  final AddressRepository _repository = AddressRepository();
  late Future<List<ShippingAddress>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchAddresses();
  }

  void _reload() {
    setState(() => _future = _repository.fetchAddresses());
  }

  Future<void> _pickOnMap() async {
    final picked = await context.push<Map<String, dynamic>>(
      '/address-selection',
    );
    if (picked == null || !mounted) return;
    final created = await context.push(
      '/address-form',
      extra: {
        'full_address': picked['display_name'],
        'latitude': picked['latitude'],
        'longitude': picked['longitude'],
      },
    );
    if (created is ShippingAddress && mounted) {
      await AddressStore.instance.select(created);
      if (mounted) Navigator.pop(context, created);
    } else if (mounted) {
      _reload();
    }
  }

  Future<void> _addNew() async {
    final created = await context.push('/address-form');
    if (created is ShippingAddress && mounted) {
      await AddressStore.instance.select(created);
      if (mounted) Navigator.pop(context, created);
    } else if (mounted) {
      _reload();
    }
  }

  void _select(ShippingAddress address) async {
    await AddressStore.instance.select(address);
    if (mounted) Navigator.pop(context, address);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pilih Alamat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<ShippingAddress?>(
              valueListenable: AddressStore.instance,
              builder: (context, selected, _) {
                return FutureBuilder<List<ShippingAddress>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final addresses = snapshot.data ?? [];
                    if (addresses.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              color: colors.textHint,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada alamat tersimpan',
                              style: TextStyle(color: colors.textHint),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pilih di peta atau tambah alamat baru.',
                              style: TextStyle(
                                color: colors.textHint,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                    return Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: addresses.length,
                        itemBuilder: (context, index) {
                          final a = addresses[index];
                          final isActive = selected?.id == a.id;
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            leading: Icon(
                              Icons.location_on_outlined,
                              color: isActive
                                  ? AppColors.primary
                                  : colors.textSecondary,
                              size: 20,
                            ),
                            title: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    (a.label ?? a.displayName),
                                    style: TextStyle(
                                      color: colors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (a.isDefault)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Utama',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isActive)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Aktif',
                                        style: TextStyle(
                                          color: AppColors.success,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${a.recipientName ?? ''} ${a.phone ?? ''}'
                                  .trim(),
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                              size: 20,
                            ),
                            onTap: () => _select(a),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickOnMap,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Pilih di Peta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addNew,
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text('Tambah Alamat Baru'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}