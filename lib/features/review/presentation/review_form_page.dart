import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/review_repository.dart';

class ReviewFormPage extends StatefulWidget {
  final String productId;

  const ReviewFormPage({super.key, required this.productId});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  final ReviewRepository _repository = ReviewRepository();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];
  int _rating = 0;
  bool _isSaving = false;
  bool _checked = false;

  static const int _maxImages = 3;

  @override
  void initState() {
    super.initState();
    _checkExistingReview();
  }

  Future<void> _checkExistingReview() async {
    try {
      final already = await _repository.hasAlreadyReviewed(widget.productId);
      if (!mounted) return;
      if (already) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamu sudah memberi ulasan untuk produk ini'),
            backgroundColor: AppColors.warning,
          ),
        );
        context.pop();
      } else {
        setState(() => _checked = true);
      }
    } catch (_) {
      if (mounted) setState(() => _checked = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await _picker.pickMultiImage(limit: _maxImages);
      setState(() {
        final remaining = _maxImages - _images.length;
        if (remaining <= 0) return;
        _images = [..._images, ...picked.take(remaining)];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_checked) return;
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih rating terlebih dahulu')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      List<String> uploadedUrls = [];
      if (_images.isNotEmpty) {
        uploadedUrls = await _repository.uploadReviewImages(_images);
      }

      await _repository.addReview(
        productId: widget.productId,
        rating: _rating,
        title: _titleController.text,
        comment: _commentController.text,
        images: uploadedUrls,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ulasan berhasil dikirim!')),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan: $e'),
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
          'Tulis Ulasan',
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              Text(
                'Bagaimana penilaianmu?',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (i) {
                    final filled = i < _rating;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          size: 38,
                          color: filled ? AppColors.rating : colors.textHint,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Foto (opsional)',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 76,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._images.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(file.path),
                                width: 76,
                                height: 76,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => setState(
                                  () => _images.removeAt(index),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_images.length < _maxImages)
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: colors.inputFill,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colors.border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_a_photo_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_images.length}/$_maxImages',
                                style: TextStyle(
                                  color: colors.textHint,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Judul',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                    hintText: 'cth: Sangat memuaskan'),
              ),
              const SizedBox(height: 20),
              Text(
                'Ulasan',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _commentController,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Ceritakan pengalamanmu dengan produk ini'),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submit,
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
                          'Kirim Ulasan',
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
}