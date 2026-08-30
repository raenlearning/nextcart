import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nextcart/core/constants/app_spacing.dart';
import 'package:nextcart/core/theme/app_colors.dart';
import 'package:nextcart/data/repository/review_repository.dart';
import 'package:nextcart/features/admin/presentation/dashboard/admin_sidebar.dart';

class AdminReviewManagementPage extends StatefulWidget {
  const AdminReviewManagementPage({super.key});

  @override
  State<AdminReviewManagementPage> createState() =>
      _AdminReviewManagementPageState();
}

class _AdminReviewManagementPageState extends State<AdminReviewManagementPage> {
  static const int _pageSize = 15;

  final ReviewRepository _repository = ReviewRepository();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  List<ProductReview> _reviews = [];
  int _total = 0;
  int _page = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;

  String _searchQuery = '';
  int? _ratingFilter;
  String _replyFilter = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load(reset: true);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 400) {
      _loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (_searchQuery == value.trim()) return;
      setState(() => _searchQuery = value.trim());
      _load(reset: true);
    });
  }

  void _onRatingFilter(int? value) {
    setState(() => _ratingFilter = value);
    _load(reset: true);
  }

  void _onReplyFilter(String value) {
    if (_replyFilter == value) return;
    setState(() => _replyFilter = value);
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _hasMore = true;
      });
    }

    try {
      final result = await _repository.fetchReviewsPage(
        page: _page,
        pageSize: _pageSize,
        search: _searchQuery,
        ratingFilter: _ratingFilter,
        replyFilter: _replyFilter,
      );
      if (!mounted) return;
      setState(() {
        _total = result.total;
        _reviews = reset ? result.items : [..._reviews, ...result.items];
        _hasMore = result.items.length >= _pageSize;
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat ulasan: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoading || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    await _load();
    if (mounted) setState(() => _isLoadingMore = false);
  }

  Future<void> _reply(ProductReview review) async {
    final controller = TextEditingController(text: review.replyText ?? '');
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Balas Ulasan'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 500,
          decoration: const InputDecoration(
            hintText: 'Tulis balasan untuk pembeli...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (submitted != true || !mounted) return;

    final text = controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Balasan tidak boleh kosong'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await _repository.replyReview(review.id, text);
      if (!mounted) return;

      final index = _reviews.indexWhere((r) => r.id == review.id);
      if (index != -1) {
        setState(() {
          _reviews[index] = ProductReview(
            id: review.id,
            productId: review.productId,
            userId: review.userId,
            rating: review.rating,
            title: review.title,
            comment: review.comment,
            images: review.images,
            replyText: text,
            replyAt: DateTime.now(),
            createdAt: review.createdAt,
            userName: review.userName,
            userAvatar: review.userAvatar,
            productName: review.productName,
          );
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Balasan berhasil disimpan!')),
      );

      AdminSidebar.refreshTrigger.value++;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan balasan: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
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
        centerTitle: false,
        title: Text(
          'Review',
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Geist',
            letterSpacing: -0.4,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => _load(reset: true),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(color: colors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari produk, pembeli, atau isi ulasan...',
                  hintStyle: TextStyle(color: colors.textHint, fontSize: 12.5),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.textSecondary,
                  ),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            color: colors.textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        ),
                  filled: true,
                  fillColor: colors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _RatingChip(
                    label: 'Semua',
                    selected: _ratingFilter == null,
                    onTap: () => _onRatingFilter(null),
                  ),
                  for (final rating in const [5, 4, 3, 2, 1])
                    _RatingChip(
                      label: '$rating',
                      showStar: true,
                      selected: _ratingFilter == rating,
                      onTap: () => _onRatingFilter(rating),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _StatusChip(
                    label: 'Semua',
                    color: colors.textSecondary,
                    selected: _replyFilter == 'all',
                    onTap: () => _onReplyFilter('all'),
                  ),
                  _StatusChip(
                    label: 'Belum dibalas',
                    color: AppColors.warning,
                    selected: _replyFilter == 'unreplied',
                    onTap: () => _onReplyFilter('unreplied'),
                  ),
                  _StatusChip(
                    label: 'Sudah dibalas',
                    color: AppColors.success,
                    selected: _replyFilter == 'replied',
                    onTap: () => _onReplyFilter('replied'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                children: [
                  Text(
                    _isLoading ? 'Memuat...' : '$_total ulasan',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2,
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _load(reset: true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    )
                  : _reviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 44,
                            color: colors.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada ulasan yang cocok',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba ubah kata kunci atau filter.',
                            style: TextStyle(
                              color: colors.textHint,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        AppSpacing.bottomNavSpace,
                      ),
                      itemCount: _reviews.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 0),
                      itemBuilder: (context, index) {
                        if (index >= _reviews.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }
                        return _AdminReviewCard(
                          review: _reviews[index],
                          onReply: () => _reply(_reviews[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final bool showStar;
  final bool selected;
  final VoidCallback onTap;

  const _RatingChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showStar = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : colors.inputFill,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showStar) ...[
                Icon(
                  Icons.star_rounded,
                  size: 13,
                  color: selected ? Colors.white : AppColors.rating,
                ),
                const SizedBox(width: 3),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? color : colors.inputFill,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: selected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminReviewCard extends StatelessWidget {
  final ProductReview review;
  final VoidCallback onReply;

  const _AdminReviewCard({required this.review, required this.onReply});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasReply = review.replyText != null && review.replyText!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: colors.inputFill,
                backgroundImage: review.userAvatar != null
                    ? CachedNetworkImageProvider(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Icon(Icons.person, color: colors.textSecondary, size: 18)
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
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review.productName ?? 'Produk tidak diketahui',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat(
                        'd MMM yyyy',
                        'id_ID',
                      ).format(review.createdAt),
                      style: TextStyle(color: colors.textHint, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return Icon(
                        i < review.rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: i < review.rating
                            ? AppColors.rating
                            : colors.textHint,
                        size: 14,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: hasReply
                          ? AppColors.success.withValues(alpha: 0.12)
                          : AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hasReply ? 'Sudah dibalas' : 'Belum dibalas',
                      style: TextStyle(
                        color: hasReply ? AppColors.success : AppColors.warning,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (review.title != null) ...[
            const SizedBox(height: 8),
            Text(
              review.title!,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
          if (review.comment != null) ...[
            const SizedBox(height: 2),
            Text(
              review.comment!,
              style: TextStyle(color: colors.textSecondary, fontSize: 12),
            ),
          ],
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: review.images.map((url) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          width: 60,
                          height: 60,
                          color: colors.inputFill,
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 60,
                          height: 60,
                          color: colors.inputFill,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: colors.textHint,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          if (hasReply) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Balasan: ${review.replyText}',
                style: TextStyle(color: colors.textPrimary, fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onReply,
              icon: const Icon(Icons.reply_outlined, size: 15),
              label: Text(hasReply ? 'Ubah Balasan' : 'Balas'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
