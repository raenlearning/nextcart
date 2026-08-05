import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class AdminRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Product>> getAdminProducts(String sellerId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat katalog: ${e.toString()}');
    }
  }

  Future<void> createProduct(Product product) async {
    try {
      await _supabase.from('products').insert(product.toJson());
    } catch (e) {
      throw Exception('Gagal menambahkan produk: ${e.toString()}');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _supabase
          .from('products')
          .update(product.toJson())
          .eq('id', product.id);
    } catch (e) {
      throw Exception('Gagal memperbarui produk: ${e.toString()}');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      final productData = await _supabase
          .from('products')
          .select('images')
          .eq('id', id)
          .maybeSingle();

      if (productData != null && productData['images'] != null) {
        final List<dynamic> imageUrls = productData['images'];
        List<String> pathsToDelete = [];

        for (String url in imageUrls) {
          if (url.contains('/product-images/')) {
            final String path = url.split('/product-images/').last;
            pathsToDelete.add(path);
          }
        }

        if (pathsToDelete.isNotEmpty) {
          await _supabase.storage
              .from('product-images')
              .remove(pathsToDelete);
          
          debugPrint("Berhasil menghapus ${pathsToDelete.length} gambar dari bucket.");
        }
      }

      await _supabase.from('products').delete().eq('id', id);

    } catch (e) {
      throw Exception('Gagal menghapus produk dan berkas gambar: ${e.toString()}');
    }
  }
}