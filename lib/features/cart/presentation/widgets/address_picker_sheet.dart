import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/service/address_store.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/address_repository.dart';

class AddressPickerSheet extends StatefulWidget {
  final void Function(Map<String, dynamic> address) onSelected;

  const AddressPickerSheet({super.key, required this.onSelected});

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
            FutureBuilder<List<ShippingAddress>>(
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
                    padding: const EdgeInsets.symmetric(vertical: 24),
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
                      final parts = [
                        a.fullAddress,
                        a.district,
                        a.city,
                        a.province,
                        a.postalCode,
                      ].whereType<String>().where((p) => p.trim().isNotEmpty);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        leading: Icon(Icons.location_on_outlined,
                            color: AppColors.primary, size: 20),
                        title: Text(
                          '${a.recipientName ?? ''} ${a.phone ?? ''}'.trim(),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(
                          parts.join(', '),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          AddressStore.instance.select(a);
                          widget.onSelected({
                            'id': a.id,
                            'full_address': a.fullAddress,
                            'province': a.province,
                            'city': a.city,
                            'district': a.district,
                            'postal_code': a.postalCode,
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final created = await context.push('/address-form');
                  if (created is ShippingAddress) {
                    await AddressStore.instance.select(created);
                    widget.onSelected({
                      'id': created.id,
                      'full_address': created.fullAddress,
                      'province': created.province,
                      'city': created.city,
                      'district': created.district,
                      'postal_code': created.postalCode,
                    });
                  }
                  if (mounted) _reload();
                },
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
    );
  }
}
