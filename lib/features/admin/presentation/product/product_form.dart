import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextcart/core/helper/supabase_storage_helper.dart';
import 'package:nextcart/core/helper/validators.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/admin/category_row.dart';
import 'package:nextcart/core/widgets/admin/media_picker_sheet.dart';
import 'package:nextcart/core/widgets/admin/status_radio.dart';
import 'package:nextcart/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/features/admin/bloc/product/admin_product_bloc.dart';
import 'package:nextcart/features/admin/bloc/product/admin_product_event.dart';
import 'package:nextcart/features/admin/presentation/product/widgets/category_picker_sheet.dart';
import 'package:nextcart/features/admin/presentation/product/widgets/product_media_tile.dart';

import '../../../../core/widgets/admin/flat_field.dart';
import '../../../../core/widgets/admin/form_section.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;
  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _weightController;

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categoriesList = [];
  bool _isLoadingCategories = true;

  List<XFile> _newSelectedImages = [];
  List<String> _existingImages = [];
  bool _isLoading = false;
  bool _isActive = true;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final currentProduct = widget.product;

    _nameController = TextEditingController(text: currentProduct?.name ?? '');
    _descController = TextEditingController(
      text: currentProduct?.description ?? '',
    );

    _priceController = TextEditingController(
      text: currentProduct?.price != null
          ? currentProduct!.price.toStringAsFixed(0)
          : '',
    );
    _stockController = TextEditingController(
      text: currentProduct?.stock != null
          ? currentProduct!.stock.toString()
          : '',
    );
    _weightController = TextEditingController(
      text: currentProduct != null && currentProduct.weightGrams > 0
          ? currentProduct.weightGrams.toString()
          : '',
    );

    _isActive = currentProduct?.isActive ?? true;
    _existingImages = currentProduct?.images != null
        ? List.from(currentProduct!.images)
        : [];
    _selectedCategoryId = currentProduct?.categoryId;

    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select('id, name, image_url, products(id, images)')
          .order('name', ascending: true);
      if (mounted) {
        setState(() {
          _categoriesList = (response as List).map((item) {
            return {
              'id': item['id'].toString(),
              'name': item['name'].toString(),
              'image_url': item['image_url'],
              'products': item['products'],
            };
          }).toList();
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
        _showSnack('Gagal mengambil kategori: $e', AppColors.error);
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _openMediaSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => MediaPickerSheet(
        existingImages: _existingImages,
        newImages: _newSelectedImages,
        picker: _picker,
        onSave: (existing, newFiles) {
          setState(() {
            _existingImages = existing;
            _newSelectedImages = newFiles;
          });
        },
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_newSelectedImages.isEmpty && _existingImages.isEmpty) {
      _showSnack('Wajib memilih minimal 1 foto produk.', AppColors.warning);
      return;
    }
    if (_selectedCategoryId == null) {
      _showSnack('Silakan pilih kategori produk.', AppColors.warning);
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> newUrls = [];
      if (_newSelectedImages.isNotEmpty) {
        newUrls = await SupabaseStorageHelper.uploadProductImages(
          _newSelectedImages,
        );
      }
      final finalImages = [..._existingImages, ...newUrls];
      final price = double.tryParse(_priceController.text.trim()) ?? 0;
      final stock = int.tryParse(_stockController.text.trim()) ?? 0;
      final weightGrams = int.tryParse(_weightController.text.trim()) ?? 0;

      if (!mounted) return;

      if (!_isEdit) {
        context.read<AdminProductBloc>().add(
          AddAdminProduct(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
            price: price,
            stock: stock,
            categoryId: _selectedCategoryId!,
            images: finalImages,
            isActive: _isActive,
            weightGrams: weightGrams,
          ),
        );
      } else {
        context.read<AdminProductBloc>().add(
          EditAdminProduct(
            Product(
              id: widget.product!.id,
              name: _nameController.text.trim(),
              description: _descController.text.trim(),
              price: price,
              stock: stock,
              categoryId: _selectedCategoryId!,
              images: finalImages,
              sellerId: widget.product!.sellerId,
              isActive: _isActive,
              weightGrams: weightGrams,
            ),
          ),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnack('Gagal memproses data: $e', AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalImages = _existingImages.length + _newSelectedImages.length;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: context.colors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEdit ? 'Edit Produk' : 'Buat Produk',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: context.colors.textOnPrimary,
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Sedang memproses...',
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  FormSection(label: "Media"),
                  ProductMediaTile(
                    totalImages: totalImages,
                    onTap: _openMediaSheet,
                  ),

                  FormSection(label: "Product Name"),
                  FlatField(
                    controller: _nameController,
                    hint: "Product name",
                    validator: (v) =>
                        Validators.requiredField(v, message: 'Nama produk wajib diisi'),
                  ),

                  FormSection(label: "Status"),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        StatusRadio(
                          label: "Active",
                          selected: _isActive,
                          onTap: () {
                            setState(() {
                              _isActive = true;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        StatusRadio(
                          label: "Inactive",
                          selected: !_isActive,
                          onTap: () {
                            setState(() {
                              _isActive = false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  FormSection(label: "Descriptions"),
                  FlatField(
                    controller: _descController,
                    hint: "Product Description",
                    maxLines: 4,
                  ),

                  FormSection(label: "Category"),
                  _isLoadingCategories
                      ? const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: LinearProgressIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.slate100,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: CategoryRow(
                            categories: _categoriesList,
                            selectedId: _selectedCategoryId,
                            onAdd: _showCategoryBottomSheet,
                          ),
                        ),

                  FormSection(label: "Price"),
                  FlatField(
                    controller: _priceController,
                    hint: "Rp 0",
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    validator: Validators.price,
                  ),

                  FormSection(label: "Stock"),
                  FlatField(
                    controller: _stockController,
                    hint: "0",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.stock,
                  ),

                  FormSection(label: "Berat (gram)"),
                  FlatField(
                    controller: _weightController,
                    hint: "cth: 250",
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: Validators.weight,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(
                      'Berat dipakai untuk menghitung ongkos kirim.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        decoration: BoxDecoration(
          color: context.colors.background,
          border: Border(top: BorderSide(color: context.colors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.textPrimary,
                  side: BorderSide(color: context.colors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isEdit ? 'Simpan Perubahan' : 'Tambah Produk',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCategoryBottomSheet() async {
    final selectedId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.colors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => CategoryPickerSheet(
        categories: _categoriesList,
        selectedId: _selectedCategoryId,
      ),
    );

    if (selectedId != null && mounted) {
      setState(() => _selectedCategoryId = selectedId);
    }
  }
}