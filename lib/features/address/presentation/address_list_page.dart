import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/address_repository.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  final AddressRepository _repository = AddressRepository();
  List<ShippingAddress> _addresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await _repository.fetchAddresses();
      if (mounted) setState(() => _addresses = data);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat alamat: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForm([ShippingAddress? address]) async {
    final result = await context.push<Map<String, dynamic>>(
      '/address-form',
      extra: address,
    );
    if (result != null) await _load();
  }

  Future<void> _confirmDelete(ShippingAddress address) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: const Text('Hapus Alamat?'),
        content: Text(
          'Hapus alamat "${address.label ?? 'ini'}" secara permanen?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: colors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _repository.deleteAddress(address.id);
        await _load();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus alamat: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _setDefault(ShippingAddress address) async {
    try {
      await _repository.updateAddress(address.id, {'is_default': true});
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengatur alamat utama: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Alamat Pengiriman',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2))
          : _error != null
              ? Center(
                  child: Text(_error!,
                      style: TextStyle(color: colors.textSecondary)))
              : _addresses.isEmpty
                  ? _EmptyState(colors: colors, onAdd: _openForm)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _load,
                      child: ListView.builder(
                        physics:
                            const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                        itemCount: _addresses.length,
                        itemBuilder: (context, index) =>
                            _AddressCard(
                          address: _addresses[index],
                          onTap: () => _openForm(_addresses[index]),
                          onDelete: () => _confirmDelete(_addresses[index]),
                          onSetDefault: () => _setDefault(_addresses[index]),
                        ),
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  const _AddressCard({
    required this.address,
    required this.onTap,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : colors.border,
          width: address.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  address.label?.isNotEmpty == true
                      ? address.label!
                      : 'Alamat',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (address.isDefault) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Utama',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.delete_outline,
                    size: 20, color: AppColors.error),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (address.recipientName != null ||
              address.phone != null) ...[
            Text(
              [address.recipientName, address.phone]
                  .whereType<String>()
                  .join(' • '),
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            address.fullAddress,
            style: TextStyle(color: colors.textSecondary, fontSize: 13),
          ),
          if (!address.isDefault) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSetDefault,
                child: const Text('Jadikan Utama'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColorScheme colors;
  final ValueChanged<ShippingAddress?> onAdd;

  const _EmptyState({required this.colors, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined,
                size: 56, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              'Belum ada alamat tersimpan',
              style: TextStyle(
                color: colors.textHint,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}