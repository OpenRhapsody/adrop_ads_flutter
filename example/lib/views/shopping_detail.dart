import 'package:flutter/material.dart';
import '../models/shopping_product.dart';
import '../theme/colors.dart';

class ShoppingDetail extends StatelessWidget {
  final ShoppingProduct product;

  const ShoppingDetail({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdropColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageSection(context),
                    _buildProductInfo(),
                    const SizedBox(height: 8),
                    _buildDeliveryInfo(),
                    const SizedBox(height: 8),
                    _buildSellerInfo(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 360,
          width: double.infinity,
          color: const Color(0xFFF0F0F0),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xB3FFFFFF),
              ),
              child: const Icon(Icons.close, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Text(
            product.brand,
            style: const TextStyle(
              fontSize: 13,
              color: AdropColors.textSecondary,
            ),
          ),
          // Name
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              product.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdropColors.textPrimary,
              ),
            ),
          ),
          // Rating
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Text(
                  '\u2605\u2605\u2605\u2605\u2605',
                  style: TextStyle(fontSize: 14, color: Color(0xFFFFB800)),
                ),
                const SizedBox(width: 6),
                Text(
                  product.rating.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AdropColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${product.reviewCount} reviews',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AdropColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Divider
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AdropColors.divider),
          ),
          // Price section
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${product.discountRate}%',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4444),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${product.formattedOriginalPrice}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AdropColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    '\$${product.formattedPrice}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AdropColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Tags
          if (product.tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: product.tags
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdropColors.primary,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Info',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdropColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Shipping',
                  style: TextStyle(
                    fontSize: 13,
                    color: AdropColors.textSecondary,
                  ),
                ),
              ),
              Text(
                'Free',
                style: TextStyle(
                  fontSize: 13,
                  color: AdropColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  'Arrival',
                  style: TextStyle(
                    fontSize: 13,
                    color: AdropColors.textSecondary,
                  ),
                ),
              ),
              Text(
                'Tomorrow (Wed)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AdropColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSellerInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seller',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AdropColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AdropColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Official Store',
                    style: TextStyle(
                      fontSize: 12,
                      color: AdropColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Wishlist button
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to wishlist')),
                );
              },
              icon: const Icon(Icons.star_border, size: 28),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: AdropColors.divider,
          ),
          // Purchase button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdropColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Purchase: ${product.name}\n\$${product.formattedPrice}'),
                    ),
                  );
                },
                child: const Text(
                  'Purchase',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
