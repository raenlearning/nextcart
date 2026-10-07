import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistRepository {
  final SupabaseClient _supabase;

  WishlistRepository({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  @visibleForTesting
  static String sortColumn(String sortBy) {
    return (sortBy == 'price_low' || sortBy == 'price_high')
        ? 'products(price)'
        : 'created_at';
  }

  @visibleForTesting
  static bool isPriceSort(String sortBy) {
    return sortBy == 'price_low' || sortBy == 'price_high';
  }

  /// Ambil semua id wishlist milik user (untuk status heart di card/detail).
  Future<Set<String>> fetchWishlistedProductIds() async {
    final userId = _userId;
    if (userId == null) return {};

    final data = await _supabase
        .from('wishlist_items')
        .select('product_id')
        .eq('user_id', userId);

    return (data as List)
        .map((row) => row['product_id'] as String)
        .toSet();
  }

  Future<List<Map<String, dynamic>>> fetchWishlist({
    String? search,
    String? categoryId,
    String sortBy = 'newest', 
    int page = 1,
    int pageSize = 20,
  }) async {
    final userId = _userId;
    if (userId == null) return [];

    var query = _supabase
        .from('wishlist_items')
        .select('''
          id,
          created_at,
          products (
            id,
            name,
            price,
            images,
            categories ( id, name )
          )
        ''')
        .eq('user_id', userId);

    if (search != null && search.trim().isNotEmpty) {
      query = query.ilike('products.name', '%${search.trim()}%');
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      final matchingProducts = await _supabase
          .from('products')
          .select('id')
          .eq('category_id', categoryId);
      final productIds = (matchingProducts as List)
          .map((p) => p['id'] as String)
          .toList();
      if (productIds.isEmpty) return [];
      query = query.inFilter('product_id', productIds);
    }

    final start = (page - 1) * pageSize;

    final data = await (isPriceSort(sortBy)
            ? query.order(sortColumn(sortBy), ascending: sortBy == 'price_low')
            : query.order(sortColumn(sortBy), ascending: false))
        .range(start, start + pageSize - 1);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> addToWishlist(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    await _supabase
        .from('wishlist_items')
        .upsert(
          {'user_id': userId, 'product_id': productId},
          onConflict: 'user_id,product_id',
        );
  }

  Future<void> removeFromWishlist(String productId) async {
    final userId = _userId;
    if (userId == null) return;
    await _supabase
        .from('wishlist_items')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
