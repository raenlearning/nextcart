import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextcart/core/constants/app_assets.dart';
import 'package:nextcart/core/helper/supabase_storage_helper.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? _resolveCategoryImage(String name) {
  final n = name.toLowerCase();
  if (n.contains('smartphone') ||
      n.contains('phone') ||
      n.contains('handphone')) {
    return AppAssets.categorySmartPhone;
  }
  if (n.contains('laptop') || n.contains('notebook')) {
    return AppAssets.categoryLaptop;
  }
  if (n.contains('audio') ||
      n.contains('earbud') ||
      n.contains('headphone') ||
      n.contains('speaker') ||
      n.contains('sound')) {
    return AppAssets.categoryAudio;
  }
  if (n.contains('game') ||
      n.contains('console') ||
      n.contains('playstation') ||
      n.contains('xbox')) {
    return AppAssets.categoryGaming;
  }
  if (n.contains('watch') ||
      n.contains('jam') ||
      n.contains('band') ||
      n.contains('wearable')) {
    return AppAssets.categoryWatch;
  }
  if (n.contains('computer') ||
      n.contains('pc') ||
      n.contains('desktop') ||
      n.contains('cpu') ||
      n.contains('motherboard')) {
    return AppAssets.categoryComputer;
  }
  if (n.contains('tv') ||
      n.contains('televisi') ||
      n.contains('monitor') ||
      n.contains('display')) {
    return AppAssets.categoryTelevision;
  }
  if (n.contains('camera') ||
      n.contains('kamera') ||
      n.contains('cam') ||
      n.contains('cctv')) {
    return AppAssets.categoryCamera;
  }
  if (n == 'other' || n == 'lainnya') return AppAssets.categoryOther;
  return null;
}

Widget _categoryThumb(String name, double width, double height) {
  final asset = _resolveCategoryImage(name);
  if (asset != null) {
    return Image.asset(asset, width: width, height: height, fit: BoxFit.cover);
  }
  final letter =
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary],
      ),
    ),
    alignment: Alignment.center,
    child: Text(
      letter,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 26,
      ),
    ),
  );
}

Widget _buildCategoryCover(String? url, String name, double width, double height) {
  if (url != null && url.isNotEmpty) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, _) => _categoryThumb(name, width, height),
      errorWidget: (_, _, _) => _categoryThumb(name, width, height),
    );
  }
  return _categoryThumb(name, width, height);
}

class AdminCategoryPage extends StatefulWidget {
  const AdminCategoryPage({super.key});

  @override
  State<AdminCategoryPage> createState() => _AdminCategoryPageState();
}

class _AdminCategoryPageState extends State<AdminCategoryPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await _supabase
          .from('categories')
          .select('id, name, image_url, products(id, images)')
          .order('name', ascending: true);
      if (!mounted) return;
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat kategori: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  int _productCount(Map<String, dynamic> category) {
    final products = category['products'] as List?;
    return products?.length ?? 0;
  }

  String? _categoryImageUrl(Map<String, dynamic> category) {
    final custom = category['image_url'];
    if (custom != null && custom.toString().isNotEmpty) return custom.toString();
    final products = category['products'] as List?;
    if (products != null && products.isNotEmpty) {
      final product = products.first as Map<String, dynamic>;
      final images = product['images'];
      if (images is List && images.isNotEmpty) {
        final first = images.first;
        if (first != null && first.toString().isNotEmpty) return first.toString();
      } else if (images != null && images.toString().isNotEmpty) {
        return images.toString();
      }
    }
    return null;
  }

  Future<void> _openForm({Map<String, dynamic>? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => _CategoryFormDialog(existing: existing),
    );

    if (saved == true) {
      await _fetchCategories();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            existing == null
                ? 'Kategori berhasil dibuat'
                : 'Kategori berhasil diperbarui',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _delete(Map<String, dynamic> category) async {
    final colors = context.colors;
    final productCount = _productCount(category);

    if (productCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Kategori masih memiliki $productCount produk. '
            'Pindahkan produknya terlebih dahulu.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Kategori?',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Kategori "${category['name']}" akan dihapus permanen.',
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
      await _supabase.from('categories').delete().eq('id', category['id']);
      await _fetchCategories();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kategori dihapus'),
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
        scrolledUnderElevation: 0,
        title: Text(
          'Kelola Kategori',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: _fetchCategories,
            icon: Icon(Icons.refresh_rounded, color: colors.textPrimary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Tambah Kategori',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.4,
              ),
            )
          : _categories.isEmpty
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
                    child: Icon(
                      Icons.category_outlined,
                      size: 30,
                      color: colors.textHint,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Belum ada kategori.\nKetuk tombol untuk membuat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(15, 12, 15, 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.92,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final name = (category['name'] ?? '').toString();
                final productCount = _productCount(category);

                return Container(
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: colors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: _buildCategoryCover(
                              _categoryImageUrl(category),
                              name,
                              double.infinity,
                              90,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                color: colors.card,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openForm(existing: category);
                                  } else {
                                    _delete(category);
                                  }
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline,
                                          size: 16,
                                          color: AppColors.error,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text('Hapus'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: colors.inputFill,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$productCount produk',
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _CategoryFormDialog extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const _CategoryFormDialog({this.existing});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.existing?['name'] ?? '',
  );

  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl;
  XFile? _pickedImage;
  bool _removeImage = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _existingImageUrl = (widget.existing?['image_url'] as String?)?.toString();
    _nameController.addListener(() => setState(() {}));
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _pickedImage = picked);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama kategori tidak boleh kosong.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      String? finalUrl = _existingImageUrl;

      if (_pickedImage != null) {
        finalUrl = await SupabaseStorageHelper.uploadCategoryImage(_pickedImage!);
        if (_existingImageUrl != null && _existingImageUrl != finalUrl) {
          await SupabaseStorageHelper.deleteCategoryImageByUrl(_existingImageUrl!);
        }
      } else if (_removeImage) {
        if (_existingImageUrl != null) {
          await SupabaseStorageHelper.deleteCategoryImageByUrl(_existingImageUrl!);
        }
        finalUrl = null;
      }

      if (_isEdit) {
        await supabase
            .from('categories')
            .update({'name': name, 'image_url': finalUrl})
            .eq('id', widget.existing!['id']);
      } else {
        await supabase
            .from('categories')
            .insert({'name': name, 'image_url': finalUrl});
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('duplicate')
                ? 'Kategori dengan nama itu sudah ada.'
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

    return AlertDialog(
      backgroundColor: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        _isEdit ? 'Edit Kategori' : 'Kategori Baru',
        style: TextStyle(color: colors.textPrimary),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _pickedImage != null
                    ? Image.file(
                        File(_pickedImage!.path),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : _buildCategoryCover(
                        _removeImage ? null : _existingImageUrl,
                        _nameController.text.trim().isNotEmpty
                            ? _nameController.text.trim()
                            : (widget.existing?['name'] as String? ?? ''),
                        80,
                        80,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                  label: const Text('Pilih Gambar'),
                ),
                if (_existingImageUrl != null || _pickedImage != null)
                  TextButton.icon(
                    onPressed: () => setState(() {
                      _pickedImage = null;
                      _removeImage = true;
                    }),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(color: colors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Misal: Aksesoris',
                hintStyle: TextStyle(color: colors.textHint),
                filled: true,
                fillColor: colors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: Text(_isEdit ? 'Simpan' : 'Buat'),
        ),
      ],
    );
  }
}
