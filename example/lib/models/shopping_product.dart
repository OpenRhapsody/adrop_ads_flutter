class ShoppingProduct {
  final String id;
  final String name;
  final String brand;
  final int price;
  final int discountRate;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final List<String> tags;

  const ShoppingProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.discountRate,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.tags = const [],
  });

  int get discountedPrice => price * (100 - discountRate) ~/ 100;

  String get formattedPrice => _formatNumber(discountedPrice);

  String get formattedOriginalPrice => _formatNumber(price);

  static String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  static List<ShoppingProduct> dummyProducts() => const [
        ShoppingProduct(
          id: 'shop_001',
          name: 'Premium Wireless Earbuds Pro Max',
          brand: 'SoundTech',
          price: 189000,
          discountRate: 35,
          imageUrl: 'https://picsum.photos/seed/earphone/400/400',
          rating: 4.8,
          reviewCount: 2341,
          tags: ['Free Shipping'],
        ),
        ShoppingProduct(
          id: 'shop_002',
          name: 'Organic Cotton Oversized Sweatshirt',
          brand: 'DailyWear',
          price: 49900,
          discountRate: 20,
          imageUrl: 'https://picsum.photos/seed/sweater/400/400',
          rating: 4.5,
          reviewCount: 876,
          tags: ['Free Shipping'],
        ),
        ShoppingProduct(
          id: 'shop_003',
          name: 'Smart Air Purifier 2nd Gen',
          brand: 'CleanAir',
          price: 299000,
          discountRate: 40,
          imageUrl: 'https://picsum.photos/seed/purifier/400/400',
          rating: 4.7,
          reviewCount: 1523,
          tags: ['Free Shipping', 'Sale'],
        ),
        ShoppingProduct(
          id: 'shop_004',
          name: 'Retro Mini Bluetooth Speaker',
          brand: 'RetroSound',
          price: 68000,
          discountRate: 15,
          imageUrl: 'https://picsum.photos/seed/speaker/400/400',
          rating: 4.3,
          reviewCount: 432,
          tags: ['Ships Today'],
        ),
        ShoppingProduct(
          id: 'shop_005',
          name: 'Genuine Leather Mini Crossbody Bag',
          brand: 'LeatherCraft',
          price: 129000,
          discountRate: 25,
          imageUrl: 'https://picsum.photos/seed/bag/400/400',
          rating: 4.6,
          reviewCount: 1089,
          tags: ['Limited Stock'],
        ),
        ShoppingProduct(
          id: 'shop_006',
          name: 'Ultra Light Running Shoes AirMax',
          brand: 'RunFast',
          price: 159000,
          discountRate: 30,
          imageUrl: 'https://picsum.photos/seed/shoes/400/400',
          rating: 4.9,
          reviewCount: 3210,
          tags: ['Free Shipping', 'Best'],
        ),
      ];
}
