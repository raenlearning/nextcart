import 'package:supabase_flutter/supabase_flutter.dart';

class ProductReview {
  final int id;
  final String productId;
  final String userId;
  final int rating;
  final String? title;
  final String? comment;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.title,
    this.comment,
    required this.createdAt,
    this.userName,
    this.userAvatar,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final user = json['profiles'] as Map<String, dynamic>?;
    return ProductReview(
      id: (json['id'] as num).toInt(),
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['full_name'] as String?,
      userAvatar: user?['avatar_url'] as String?,
    );
  }
}

class ReviewRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductReview>> fetchReviews(String productId) async {
    final data = await _supabase
        .from('reviews')
        .select('''
          id,
          product_id,
          user_id,
          rating,
          title,
          comment,
          created_at,
          profiles(full_name, avatar_url)
        ''')
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => ProductReview.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> hasReviewed(String productId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return true;

    final data = await _supabase
        .from('reviews')
        .select('id')
        .eq('product_id', productId)
        .eq('user_id', userId)
        .maybeSingle();

    return data != null;
  }

  Future<void> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Silakan login terlebih dahulu.');

    await _supabase.from('reviews').insert({
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'title': title?.trim().isEmpty == true ? null : title?.trim(),
      'comment': comment?.trim().isEmpty == true ? null : comment?.trim(),
    });
  }
}