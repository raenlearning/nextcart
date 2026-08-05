import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Product>> getPopularProducts() async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .limit(5);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data produk: ${e.toString()}');
    }
  }

  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .eq('category_id', categoryId)
          .limit(5); 

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memfilter kategori: ${e.toString()}');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _supabase
          .from('products')
          .select()
          .eq('is_active', true)
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mencari produk: ${e.toString()}');
    }
  }
}