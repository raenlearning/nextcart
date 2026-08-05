import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/address_repository.dart';

class AddressFormPage extends StatefulWidget {
  final ShippingAddress? address;

  const AddressFormPage({super.key, this.address});

  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final AddressRepository _repository = AddressRepository();
  bool _isDefault = false;
  bool _isSaving = false;

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    if (a != null) {
      _labelController.text = a.label ?? '';
      _recipientController.text = a.recipientName ?? '';
      _phoneController.text = a.phone ?? '';
      _addressController.text = a.fullAddress;
      _isDefault = a.isDefault;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final fields = {
        'label': _labelController.text.trim().isEmpty
            ? null
            : _labelController.text.trim(),
        'recipient_name': _recipientController.text.trim(),
        'phone': _phoneController.text.trim(),
        'full_address': _addressController.text.trim(),
        'is_default': _isDefault,
      };

      if (_isEditing) {
        await _repository.updateAddress(widget.address!.id, fields);
      } else {
        await _repository.createAddress(fields);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Alamat berhasil diperbarui!'
                : 'Alamat berhasil ditambahkan!'),
          ),
        );
        context.pop({'saved': true});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan alamat: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          _isEditing ? 'Edit Alamat' : 'Tambah Alamat',
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _label('Label'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _labelController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'cth: Rumah, Kantor'),
              ),
              const SizedBox(height: 20),
              _label('Nama Penerima'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _recipientController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(hintText: 'Nama penerima'),
              ),
              const SizedBox(height: 20),
              _label('Nomor Telepon'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _phoneController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(hintText: '08xxxxxxxxxx'),
              ),
              const SizedBox(height: 20),
              _label('Alamat Lengkap'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Masukkan alamat lengkap'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                value: _isDefault,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Jadikan alamat utama',
                  style: TextStyle(color: colors.textPrimary, fontSize: 13.5),
                ),
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Alamat',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    final colors = context.colors;
    return Text(
      text,
      style: TextStyle(
        color: colors.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }
}