import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/widgets/admin/tab_item.dart';

class MediaPickerSheet extends StatefulWidget {
  final List<String> existingImages;
  final List<XFile> newImages;
  final ImagePicker picker;
  final void Function(List<String> existing, List<XFile> newFiles) onSave;

  const MediaPickerSheet({
    super.key,
    required this.existingImages,
    required this.newImages,
    required this.picker,
    required this.onSave,
  });

  @override
  State<MediaPickerSheet> createState() => _MediaPickerSheetState();
}

class _MediaPickerSheetState extends State<MediaPickerSheet> {
  late List<String> _existing;
  late List<XFile> _newFiles;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _existing = List.from(widget.existingImages);
    _newFiles = List.from(widget.newImages);
  }

  Future<void> _pickMore() async {
    final picked = await widget.picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _newFiles.addAll(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSelected = _existing.length + _newFiles.length;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Sheet header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Tambah Media',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: context.colors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tab bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 38,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  TabItem(
                    label: 'Perpustakaan Konten',
                    selected: _tabIndex == 0,
                    onTap: () => setState(() => _tabIndex = 0),
                  ),
                  TabItem(
                    label: 'Unggah Baru',
                    selected: _tabIndex == 1,
                    onTap: () async {
                      setState(() => _tabIndex = 1);
                      await _pickMore();
                    },
                  ),
                ],
              ),
            ),
          ),

          // Selected count + unselect all
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(
                  'Selected $totalSelected',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (totalSelected > 0)
                  GestureDetector(
                    onTap: () => setState(() {
                      _existing.clear();
                      _newFiles.clear();
                    }),
                    child: const Text(
                      'Hapus semua pilihan',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Grid images
          // Grid images
          Expanded(
            child: _tabIndex == 0
                // --- TAMPILAN TAB 0: CONTENT LIBRARY (EXISTING IMAGES) ---
                ? (_existing.isEmpty
                      ? _buildEmptyState('Belum ada foto di library', null)
                      : GridView.builder(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _existing.length,
                          itemBuilder: (_, i) {
                            final url = _existing[i];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(
                                    color: Colors.grey.shade200,
                                  ),
                                  errorWidget: (_, _, _) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                    ),
                                  ),
                                ),
                                ),
                                // Tombol Hapus Existing Image
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _existing.remove(url)),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors
                                            .red, // Warna merah untuk hapus
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ))
                // --- TAMPILAN TAB 1: UPLOAD NEW (NEW FILES DARI GALERI) ---
                : (_newFiles.isEmpty
                      ? _buildEmptyState(
                          'Belum ada foto baru dipilih',
                          _pickMore,
                        )
                      : GridView.builder(
                          controller: controller,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _newFiles.length,
                          itemBuilder: (_, i) {
                            final file = _newFiles[i];
                            return Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(file.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Checkmark / Hapus New Image
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _newFiles.remove(file)),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        )),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: context.colors.background,
              border:  Border(top: BorderSide(color: context.colors.divider,)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.colors.textPrimary,
                      side:  BorderSide(color: context.colors.border),
                      padding: const EdgeInsets.symmetric(vertical: 13),
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
                    onPressed: () {
                      widget.onSave(_existing, _newFiles);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, VoidCallback? action) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            color: AppColors.slate300,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 12.5,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: action,
              icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
              label: const Text('Pilih dari galeri'),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }
}
