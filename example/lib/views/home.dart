import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adrop Ads Example"),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 24,
            ),
            TextButton(
                onPressed: () {
                  Adrop.initialize(false);
                },
                child: const Text('Adrop Initialize')),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/bannerExample');
                },
                child: const Text('Banner Example')),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/interstitialExample');
                },
                child: const Text('InterstitialAd Example')),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/rewardedExample');
                },
                child: const Text('RewardedAd Example')),
          ],
        ),
      ),
    );
  }
}
