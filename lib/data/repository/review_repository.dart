import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductReview {
  final int id;
  final String productId;
  final String userId;
  final int rating;
  final String? title;
  final String? comment;
  final List<String> images;
  final String? replyText;
  final DateTime? replyAt;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatar;
  final String? productName;

  ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.rating,
    this.title,
    this.comment,
    this.images = const [],
    this.replyText,
    this.replyAt,
    required this.createdAt,
    this.userName,
    this.userAvatar,
    this.productName,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    final user = json['profiles'] as Map<String, dynamic>?;
    final product = json['products'] as Map<String, dynamic>?;
    return ProductReview(
      id: (json['id'] as num).toInt(),
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      rating: (json['rating'] as num).toInt(),
      title: json['title'] as String?,
      comment: json['comment'] as String?,
      images: List<String>.from(json['images'] ?? []),
      replyText: json['reply_text'] as String?,
      replyAt: json['reply_at'] != null
          ? DateTime.tryParse(json['reply_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: user?['full_name'] as String?,
      userAvatar: user?['avatar_url'] as String?,
      productName: product?['name'] as String?,
    );
  }
}

class ReviewRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ProductReview>> fetchReviews(
    String productId, {
    int? ratingFilter,
  }) async {
    var query = _supabase
        .from('reviews')
        .select('''
          id,
          product_id,
          user_id,
          rating,
          title,
          comment,
          images,
          reply_text,
          reply_at,
          created_at,
          profiles(full_name, avatar_url)
        ''')
        .eq('product_id', productId);

    if (ratingFilter != null) {
      query = query.eq('rating', ratingFilter);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List)
        .map((json) => ProductReview.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Semua ulasan (untuk halaman admin).
  Future<List<ProductReview>> fetchAllReviews() async {
    final data = await _supabase
        .from('reviews')
        .select('''
          id,
          product_id,
          user_id,
          rating,
          title,
          comment,
          images,
          reply_text,
          reply_at,
          created_at,
          products(name),
          profiles(full_name, avatar_url)
        ''')
        .order('created_at', ascending: false);

    return (data as List)
        .map((json) => ProductReview.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Balasan admin ke sebuah ulasan (via RPC, memvalidasi role admin).
  Future<void> replyReview(int reviewId, String text) async {
    final result = await _supabase.rpc(
      'reply_review',
      params: {'p_review_id': reviewId, 'p_text': text},
    );
    final map = Map<String, dynamic>.from(result as Map);
    if (map['ok'] != true) {
      throw Exception(map['error']?.toString() ?? 'Gagal membalas ulasan.');
    }
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

  /// Upload foto ulasan ke bucket `review-images`.
  Future<List<String>> uploadReviewImages(List<XFile> files) async {
    List<String> urls = [];
    List<String> paths = [];
    try {
      for (var file in files) {
        final fileBytes = await file.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        final path = 'reviews/$fileName';

        await _supabase.storage.from('review-images').uploadBinary(
              path,
              fileBytes,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        urls.add(_supabase.storage.from('review-images').getPublicUrl(path));
        paths.add(path);
      }
      return urls;
    } catch (e) {
      if (paths.isNotEmpty) {
        await _supabase.storage.from('review-images').remove(paths);
      }
      rethrow;
    }
  }

  Future<void> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String> images = const [],
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Silakan login terlebih dahulu.');

    await _supabase.from('reviews').insert({
      'product_id': productId,
      'user_id': userId,
      'rating': rating,
      'title': title?.trim().isEmpty == true ? null : title?.trim(),
      'comment': comment?.trim().isEmpty == true ? null : comment?.trim(),
      'images': images,
    });
  }
}
