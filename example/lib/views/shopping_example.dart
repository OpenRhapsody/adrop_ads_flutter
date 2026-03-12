import 'package:flutter/material.dart';
import '../models/shopping_product.dart';
import '../theme/colors.dart';
import 'shopping_detail.dart';

class ShoppingExample extends StatefulWidget {
  const ShoppingExample({super.key});

  @override
  State<ShoppingExample> createState() => _ShoppingExampleState();
}

class _ShoppingExampleState extends State<ShoppingExample> {
  int _selectedTab = 0;
  final _tabs = const ['All', 'Popular', 'New'];
  final _products = ShoppingProduct.dummyProducts();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdropColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildToolbar(),
            const Divider(height: 1, color: AdropColors.divider),
            _buildTabs(),
            const Divider(height: 1, color: AdropColors.divider),
            Expanded(child: _buildProductGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Shopping Ad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AdropColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final selected = _selectedTab == i;
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected
                      ? AdropColors.primary.withValues(alpha: 0.1)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(16),
                  border: selected
                      ? Border.all(color: AdropColors.primary, width: 1)
                      : null,
                ),
                child: Text(
                  _tabs[i],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? AdropColors.primary
                        : AdropColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.46,
        crossAxisSpacing: 0,
        mainAxisSpacing: 0,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) => _ProductCard(
        product: _products[index],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShoppingDetail(product: _products[index]),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ShoppingProduct product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFFF0F0F0),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),
              // Product Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      Text(
                        product.brand,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AdropColors.textSecondary,
                        ),
                      ),
                      // Name
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AdropColors.textPrimary,
                          ),
                        ),
                      ),
                      // Discount + Price
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Text(
                              '${product.discountRate}%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF4444),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '\$${product.formattedPrice}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AdropColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Original Price
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '\$${product.formattedOriginalPrice}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AdropColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      // Rating
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            const Text(
                              '\u2605',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFFFB800),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AdropColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewCount})',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AdropColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tags
                      if (product.tags.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: product.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF0F4FF),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        tag,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AdropColors.primary,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
