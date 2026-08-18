import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/review_repository.dart';

class ReviewListPage extends StatefulWidget {
  final String productId;

  const ReviewListPage({super.key, required this.productId});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  final ReviewRepository _repository = ReviewRepository();
  List<ProductReview> _reviews = [];
  bool _isLoading = true;
  String? _error;
  int? _ratingFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data =
          await _repository.fetchReviews(widget.productId, ratingFilter: _ratingFilter);
      if (mounted) setState(() => _reviews = data);
    } catch (e) {
      if (mounted) setState(() => _error = 'Gagal memuat ulasan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openForm() async {
    final hasAlreadyReviewed =
        await _repository.hasAlreadyReviewed(widget.productId);
    if (!mounted) return;

    if (hasAlreadyReviewed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Kamu sudah memberi ulasan untuk produk ini')),
      );
      return;
    }

    final result = await context.push<bool>('/review-form',
        extra: widget.productId);
    if (result == true) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Ulasan Produk',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildFilterBar(colors),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : _error != null
                    ? Center(
                        child: Text(_error!,
                            style: TextStyle(color: colors.textSecondary)))
                    : _reviews.isEmpty
                        ? _EmptyState(colors: colors, onWrite: _openForm)
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                            itemCount: _reviews.length,
                            itemBuilder: (context, index) =>
                                _ReviewCard(review: _reviews[index]),
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _openForm,
        icon: const Icon(Icons.rate_review_outlined),
        label: const Text('Tulis Ulasan'),
      ),
    );
  }

  Widget _buildFilterBar(AppColorScheme colors) {
    final filters = <int?>[null, 5, 4, 3, 2, 1];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 34,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: filters.map((f) {
            final selected = _ratingFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f == null ? 'Semua' : '$f★'),
                selected: selected,
                onSelected: (_) {
                  setState(() => _ratingFilter = f);
                  _load();
                },
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : colors.textPrimary,
                ),
                selectedColor: AppColors.primary,
                backgroundColor: colors.inputFill,
                side: BorderSide(color: selected ? AppColors.primary : colors.border),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ProductReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colors.inputFill,
                backgroundImage: review.userAvatar != null
                    ? CachedNetworkImageProvider(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Icon(Icons.person, color: colors.textSecondary, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Pengguna',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM yyyy', 'id_ID')
                          .format(review.createdAt),
                      style: TextStyle(color: colors.textHint, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _StarRating(rating: review.rating, size: 14),
            ],
          ),
          if (review.title != null) ...[
            const SizedBox(height: 10),
            Text(
              review.title!,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ],
          if (review.comment != null) ...[
            const SizedBox(height: 4),
            Text(
              review.comment!,
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: review.images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          width: 76,
                          height: 76,
                          color: colors.inputFill,
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 76,
                          height: 76,
                          color: colors.inputFill,
                          child: Icon(Icons.broken_image_outlined,
                              color: colors.textHint, size: 24),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (review.replyText != null && review.replyText!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.storefront_outlined,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Balasan Toko',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.replyText!,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 12.5,
                    ),
                  ),
                  if (review.replyAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('d MMM yyyy', 'id_ID')
                          .format(review.replyAt!),
                      style: TextStyle(color: colors.textHint, fontSize: 10.5),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final AppColorScheme colors;
  final VoidCallback onWrite;

  const _EmptyState({required this.colors, required this.onWrite});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.reviews_outlined, size: 56, color: colors.textHint),
            const SizedBox(height: 16),
            Text(
              'Belum ada ulasan untuk produk ini',
              style: TextStyle(
                color: colors.textHint,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating;
  final double size;

  const _StarRating({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: i < rating ? AppColors.rating : context.colors.textHint,
          size: size,
        );
      }),
    );
  }
}