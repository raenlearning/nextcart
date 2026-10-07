import 'package:flutter/material.dart';
import 'package:nextcart/core/widgets/user/product/product_card.dart';
import 'package:nextcart/data/models/product_model.dart';

class HomeProductGrid extends StatelessWidget {
  final List<Product> products;

  const HomeProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.66,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) => _AnimatedProductCard(
        index: index,
        product: products[index],
      ),
    );
  }
}

class _AnimatedProductCard extends StatefulWidget {
  final int index;
  final Product product;

  const _AnimatedProductCard({required this.index, required this.product});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    Future.delayed(Duration(milliseconds: 60 * (widget.index % 4)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ProductCard(product: widget.product),
      ),
    );
  }
}
