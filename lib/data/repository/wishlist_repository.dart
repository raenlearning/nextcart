import 'package:supabase_flutter/supabase_flutter.dart';

class WishlistRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

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

  /// Ambil daftar wishlist lengkap dengan produk + kategori,
  /// mendukung search, filter kategori, sort, dan pagination.
  Future<List<Map<String, dynamic>>> fetchWishlist({
    String? search,
    String? categoryId,
    String sortBy = 'newest', // newest | price_low | price_high
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
      query = query.eq('products.categories.id', categoryId);
    }

    final start = (page - 1) * pageSize;

    final data = await query
        .order(
          sortBy == 'price_low' || sortBy == 'price_high'
              ? 'products.price'
              : 'created_at',
          ascending: sortBy == 'price_low',
        )
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
