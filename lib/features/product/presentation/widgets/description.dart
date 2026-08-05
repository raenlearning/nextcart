import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class Description extends StatefulWidget {
  final String description;
  final AppColorScheme colors;

  const Description({super.key, required this.description, required this.colors});

  @override
  State<Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<Description> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.description.isNotEmpty
        ? widget.description
        : 'Produk original berkualitas tinggi dengan garansi resmi. Dirancang untuk performa terbaik dan kenyamanan penggunaan sehari-hari.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: widget.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.colors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
          secondChild: Text(
            text,
            style: TextStyle(
              color: widget.colors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(
            _expanded ? 'Tampilkan lebih sedikit' : 'Baca selengkapnya',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}