import 'package:flutter/material.dart';
import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import '../theme/typography.dart';
import '../theme/styles.dart';
import '../views/banner_example.dart';
import '../views/interstitial_example.dart';
import '../views/rewarded_example.dart';
import '../views/native_example.dart';
import '../views/property_example.dart';
import '../views/consent_example.dart';
import '../views/shopping_example.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  void _initDebug() {
    Adrop.initialize(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SDK initialized (Debug)')),
    );
  }

  void _initProd() {
    Adrop.initialize(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('SDK initialized (Production)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Developer Tools', style: AdropTypography.screenTitle),
            const SizedBox(height: 16),

            // SDK Control
            const Text('SDK Control', style: AdropTypography.sectionTitle),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: AdropStyles.filledButton,
                    onPressed: _initDebug,
                    child: const Text('Init Debug'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: AdropStyles.outlinedButton,
                    onPressed: _initProd,
                    child: const Text('Init Prod'),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // Ad Format Test (navigate to existing example screens)
            const Text('Ad Format Test', style: AdropTypography.sectionTitle),
            const SizedBox(height: 12),
            _buildTestNavGrid(),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTestNavGrid() {
    final items = [
      {
        'label': 'Banner',
        'icon': Icons.view_agenda,
        'builder': () => const BannerExample()
      },
      {
        'label': 'Interstitial',
        'icon': Icons.fullscreen,
        'builder': () => const InterstitialExample()
      },
      {
        'label': 'Rewarded',
        'icon': Icons.card_giftcard,
        'builder': () => const RewardedExample()
      },
      {
        'label': 'Native',
        'icon': Icons.dashboard_customize,
        'builder': () => const NativeExample()
      },
      {
        'label': 'Property',
        'icon': Icons.tune,
        'builder': () => PropertyExample()
      },
      {
        'label': 'Consent',
        'icon': Icons.privacy_tip,
        'builder': () => const ConsentExample()
      },
      {
        'label': 'Shopping Ad',
        'icon': Icons.shopping_bag,
        'builder': () => const ShoppingExample()
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return OutlinedButton.icon(
          style: AdropStyles.outlinedButton,
          icon: Icon(item['icon'] as IconData, size: 18),
          label: Text(item['label'] as String),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => (item['builder'] as Widget Function())()),
            );
          },
        );
      }).toList(),
    );
  }
}
