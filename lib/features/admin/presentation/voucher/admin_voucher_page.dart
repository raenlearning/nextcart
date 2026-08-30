import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVoucherPage extends StatefulWidget {
  const AdminVoucherPage({super.key});

  @override
  State<AdminVoucherPage> createState() => _AdminVoucherPageState();
}

class _AdminVoucherPageState extends State<AdminVoucherPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _vouchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVouchers();
  }

  Future<void> _fetchVouchers() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('vouchers')
          .select()
          .order('created_at', ascending: false);
      if (!mounted) return;
      setState(() {
        _vouchers = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat voucher: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _discountLabel(Map<String, dynamic> v) {
    final value = (v['discount_value'] as num?)?.toDouble() ?? 0;
    if ((v['discount_type'] ?? '') == 'percent') {
      final max = (v['max_discount'] as num?)?.toDouble();
      final base = '${value.toStringAsFixed(0)}%';
      return max != null ? '$base · Maks ${CurrencyFormatter.rupiah(max)}' : base;
    }
    return CurrencyFormatter.rupiah(value);
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _VoucherFormSheet(existing: existing),
    );

    if (saved == true) {
      await _fetchVouchers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existing == null
              ? 'Voucher berhasil dibuat'
              : 'Voucher berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _toggleActive(Map<String, dynamic> voucher) async {
    final newValue = !((voucher['is_active'] as bool?) ?? false);
    try {
      await _supabase
          .from('vouchers')
          .update({'is_active': newValue})
          .eq('id', voucher['id']);
      await _fetchVouchers();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _delete(Map<String, dynamic> voucher) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Voucher?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Voucher "${voucher['code']}" akan dihapus permanen.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _supabase.from('vouchers').delete().eq('id', voucher['id']);
      await _fetchVouchers();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voucher dihapus'),
          backgroundColor: AppColors.warning,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: AppColors.error,
        ),
      );
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
        title: Text(
          'Kelola Voucher',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _fetchVouchers,
            icon: Icon(Icons.refresh_rounded, color: colors.textPrimary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const FaIcon(FontAwesomeIcons.plus, size: 16),
        label: const Text(
          'Voucher',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.4),
            )
          : _vouchers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colors.inputFill,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: FaIcon(
                          FontAwesomeIcons.ticket,
                          size: 28,
                          color: colors.textHint,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Belum ada voucher.\nKetuk tombol untuk membuat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  itemCount: _vouchers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final v = _vouchers[index];
                    final isActive = (v['is_active'] as bool?) ?? false;
                    final usedCount = (v['used_count'] as num?)?.toInt() ?? 0;
                    final usageLimit =
                        (v['usage_limit'] as num?)?.toInt() ?? 0;
                    final validUntil =
                        DateTime.tryParse(v['valid_until'] ?? '');
                    final expired =
                        validUntil != null && validUntil.isBefore(DateTime.now());

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isActive && !expired
                              ? colors.border
                              : colors.border.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  (v['code'] ?? '').toString().toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  (v['name'] ?? '').toString(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Switch(
                                value: isActive,
                                onChanged: (_) => _toggleActive(v),
                                activeThumbColor: AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _discountLabel(v),
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 13, color: colors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                'Min. ${CurrencyFormatter.rupiah((v['min_purchase'] as num?)?.toDouble() ?? 0)}',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Icon(Icons.repeat_rounded,
                                  size: 13, color: colors.textHint),
                              const SizedBox(width: 4),
                              Text(
                                usageLimit > 0
                                    ? '$usedCount/$usageLimit terpakai'
                                    : '$usedCount terpakai',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                              if (validUntil != null) ...[
                                const SizedBox(width: 14),
                                Icon(Icons.schedule_rounded,
                                    size: 13,
                                    color: expired
                                        ? AppColors.error
                                        : colors.textHint),
                                const SizedBox(width: 4),
                                Text(
                                  expired ? 'Kedaluwarsa' : 's.d. '
                                      '${DateFormat('d MMM yy', 'id_ID').format(validUntil)}',
                                  style: TextStyle(
                                    color: expired
                                        ? AppColors.error
                                        : colors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _openForm(existing: v),
                                icon: const Icon(Icons.edit_outlined, size: 15),
                                label: const Text('Edit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              TextButton.icon(
                                onPressed: () => _delete(v),
                                icon: const Icon(Icons.delete_outline,
                                    size: 15),
                                label: const Text('Hapus'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}

class _VoucherFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const _VoucherFormSheet({this.existing});

  @override
  State<_VoucherFormSheet> createState() => _VoucherFormSheetState();
}

class _VoucherFormSheetState extends State<_VoucherFormSheet> {
  late final TextEditingController _codeController = TextEditingController(
    text: (widget.existing?['code'] ?? '').toString().toUpperCase(),
  );
  late final TextEditingController _nameController =
      TextEditingController(text: widget.existing?['name'] ?? '');
  late final TextEditingController _valueController = TextEditingController(
    text: widget.existing?['discount_value']?.toString() ?? '',
  );
  late final TextEditingController _maxDiscountController =
      TextEditingController(
    text: widget.existing?['max_discount']?.toString() ?? '',
  );
  late final TextEditingController _minPurchaseController =
      TextEditingController(
    text: ((widget.existing?['min_purchase'] ?? 0) as num)
        .toDouble()
        .toStringAsFixed(0),
  );

  late String _type =
      (widget.existing?['discount_type'] ?? 'fixed').toString();

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _valueController.dispose();
    _maxDiscountController.dispose();
    _minPurchaseController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final value = double.tryParse(_valueController.text.replaceAll(',', '.'));
    final minPurchase =
        double.tryParse(_minPurchaseController.text.replaceAll(',', '.')) ?? 0;
    final maxDiscount =
        double.tryParse(_maxDiscountController.text.replaceAll(',', '.'));

    if (code.isEmpty || name.isEmpty || value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi kode, nama, dan nilai diskon.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    if (_type == 'percent' && value > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diskon persen tidak boleh lebih dari 100.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final payload = <String, dynamic>{
      'code': code,
      'name': name,
      'discount_type': _type,
      'discount_value': value,
      'min_purchase': minPurchase,
      'max_discount': _type == 'percent' ? maxDiscount : null,
    };

    try {
      final supabase = Supabase.instance.client;
      if (_isEdit) {
        await supabase
            .from('vouchers')
            .update(payload)
            .eq('id', widget.existing!['id']);
      } else {
        await supabase.from('vouchers').insert(payload);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('duplicate')
                ? 'Kode voucher sudah dipakai.'
                : 'Gagal menyimpan: $e',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isEdit ? 'Edit Voucher' : 'Voucher Baru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _Field(
                  controller: _codeController,
                  label: 'Kode',
                  hint: 'GEBYAR2026',
                  colors: colors,
                  uppercase: true,
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _nameController,
                  label: 'Nama Voucher',
                  hint: 'Promo Tahun Baru',
                  colors: colors,
                ),
                const SizedBox(height: 12),
                Text(
                  'Tipe Diskon',
                  style: TextStyle(fontSize: 11.5, color: colors.textSecondary),
                ),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'fixed', label: Text('Nominal')),
                    ButtonSegment(value: 'percent', label: Text('Persen')),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) =>
                      setState(() => _type = selection.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _Field(
                  controller: _valueController,
                  label: _type == 'percent' ? 'Nilai (%)' : 'Nilai (Rp)',
                  hint: _type == 'percent' ? '25' : '15000',
                  colors: colors,
                  number: true,
                ),
                if (_type == 'percent') ...[
                  const SizedBox(height: 12),
                  _Field(
                    controller: _maxDiscountController,
                    label: 'Maksimal Diskon (Rp)',
                    hint: 'Opsional, misal 50000',
                    colors: colors,
                    number: true,
                  ),
                ],
                const SizedBox(height: 12),
                _Field(
                  controller: _minPurchaseController,
                  label: 'Minimal Belanja (Rp)',
                  hint: '0',
                  colors: colors,
                  number: true,
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isEdit ? 'Simpan Perubahan' : 'Buat Voucher',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final AppColorScheme colors;
  final bool number;
  final bool uppercase;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.colors,
    this.number = false,
    this.uppercase = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11.5, color: colors.textSecondary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: number ? TextInputType.number : TextInputType.text,
          inputFormatters: [
            if (number) FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            if (uppercase) FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
          textCapitalization:
              uppercase ? TextCapitalization.characters : TextCapitalization.none,
          style: TextStyle(color: colors.textPrimary, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: colors.inputFill,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
