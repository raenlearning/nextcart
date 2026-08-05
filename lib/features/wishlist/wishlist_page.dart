import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/core/helper/currency_formatter.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => WishlistPageState();
}

class WishlistPageState extends State<WishlistPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      final data = await _supabase
          .from('wishlist_items')
          .select('''
            id,
            product_id,
            products (
              id,
              name,
              price,
              images,
              categories ( name )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        _wishlistItems = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat wishlist: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _removeFromWishlist(String wishlistItemId, int index) async {
    final removedItem = _wishlistItems[index];
    setState(() => _wishlistItems.removeAt(index));

    try {
      await _supabase.from('wishlist_items').delete().eq('id', wishlistItemId);
    } catch (e) {
      setState(() => _wishlistItems.insert(index, removedItem));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus dari wishlist',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> refresh() => _fetchWishlist();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Wishlist',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _wishlistItems.isEmpty
          ? _buildEmptyState(colors)
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _fetchWishlist,
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                itemCount: _wishlistItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index) {
                  return _buildWishlistCard(colors, index);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_border, size: 64, color: colors.textHint),
          const SizedBox(height: 12),
          Text(
            'Wishlist kamu masih kosong',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(AppColorScheme colors, int index) {
    final wishlistItem = _wishlistItems[index];
    final product = wishlistItem['products'] as Map<String, dynamic>?;

    if (product == null) return const SizedBox.shrink();

    final images = product['images'] as List<dynamic>? ?? [];
    final imageUrl = images.isNotEmpty ? images[0] as String : null;
    final category = product['categories'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String? ?? '';
    final name = product['name'] as String? ?? 'Produk';
    final price = product['price'];

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar produk
          Expanded(
            child: Center(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.image_not_supported_outlined,
                        color: colors.textHint,
                        size: 40,
                      ),
                    )
                  : Icon(
                      Icons.shopping_bag_outlined,
                      color: colors.textHint,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(height: 10),

          // Nama & harga
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.rupiah(price),
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),

          // Kategori & tombol aksi
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.favorite,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _removeFromWishlist(wishlistItem['id'], index),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: colors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: colors.background, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
