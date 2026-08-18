import 'package:flutter/material.dart';
import 'package:nextcart/core/theme/app_colors.dart';

class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final slide = -1.5 + (t * 3.0);

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + slide, 0),
              end: Alignment(slide, 0),
              colors: [
                colors.shimmerBase,
                colors.shimmerHighlight,
                colors.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerProductGrid extends StatelessWidget {
  final int itemCount;
  final double childAspectRatio;
  final EdgeInsets padding;

  const ShimmerProductGrid({
    super.key,
    this.itemCount = 6,
    this.childAspectRatio = 0.66,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 0),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const _ShimmerProductCard(),
    );
  }
}

class _ShimmerProductCard extends StatelessWidget {
  const _ShimmerProductCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: ShimmerBox(height: double.infinity, radius: 14),
            ),
          ),
          SizedBox(height: 12),
          ShimmerBox(width: double.infinity, height: 12, radius: 6),
          SizedBox(height: 8),
          ShimmerBox(width: 80, height: 12, radius: 6),
          SizedBox(height: 12),
          ShimmerBox(width: 100, height: 16, radius: 6),
        ],
      ),
    );
  }
}
