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
      itemBuilder: (context, index) => ProductCard(product: products[index]),
    );
  }
}