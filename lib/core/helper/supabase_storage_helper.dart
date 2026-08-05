import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  static Future<List<String>> uploadProductImages(List<XFile> files) async {
    List<String> uploadedUrls = [];
    List<String> uploadedPaths = [];

    try {
      for (var file in files) {
        final fileBytes = await file.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final path = 'products/$fileName';

        await _supabase.storage.from('product-images').uploadBinary(
              path,
              fileBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );

        final String publicUrl =
            _supabase.storage.from('product-images').getPublicUrl(path);

        uploadedUrls.add(publicUrl);
        uploadedPaths.add(path);
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