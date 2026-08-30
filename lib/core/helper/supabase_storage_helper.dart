import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<String> uploadCategoryImage(XFile file) async {
    final fileBytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final path = 'categories/$fileName';

    await _supabase.storage.from('category-images').uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    return _supabase.storage.from('category-images').getPublicUrl(path);
  }

  static Future<void> deleteCategoryImageByUrl(String url) async {
    try {
      const marker = '/category-images/';
      if (!url.contains(marker)) return;
      final path = url.substring(url.indexOf(marker) + marker.length);
      await _supabase.storage.from('category-images').remove([path]);
    } catch (_) {
      // Abaikan kegagalan hapus (gambar mungkin sudah tidak ada).
    }
  }

  static Future<List<String>> uploadProductImages(List<XFile> files) async {
    List<String> uploadedUrls = [];
    List<String> uploadedPaths = [];

    try {
      final results = await Future.wait(files.asMap().entries.map((entry) async {
        final index = entry.key;
        final file = entry.value;
        final fileBytes = await file.readAsBytes();
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${index}_${file.name}';
        final path = 'products/$fileName';

        await _supabase.storage.from('product-images').uploadBinary(
              path,
              fileBytes,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        final String publicUrl =
            _supabase.storage.from('product-images').getPublicUrl(path);

        return (url: publicUrl, path: path);
      }));

      for (final r in results) {
        uploadedUrls.add(r.url);
        uploadedPaths.add(r.path);
      }

      return uploadedUrls;
    } catch (e) {
      if (uploadedPaths.isNotEmpty) {
        await _supabase.storage
            .from('product-images')
            .remove(uploadedPaths);
      }
      rethrow;
    }
  }
}