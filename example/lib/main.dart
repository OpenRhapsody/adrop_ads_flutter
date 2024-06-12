import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/views/banner_example.dart';
import 'package:adrop_ads_flutter_example/views/home.dart';
import 'package:adrop_ads_flutter_example/views/interstitial_example.dart';
import 'package:adrop_ads_flutter_example/views/popup_example.dart';
import 'package:adrop_ads_flutter_example/views/property_example.dart';
import 'package:adrop_ads_flutter_example/views/rewarded_example.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
  Adrop.initialize(false);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/home',
      navigatorObservers: [AdropNavigatorObserver()],
      routes: {
        '/home': (context) => const Home(),
        '/bannerExample': (context) => const BannerExample(),
        '/interstitialExample': (_) => const InterstitialExample(),
        '/rewardedExample': (_) => const RewardedExample(),
        '/popupExample': (_) => const PopupExample(),
        '/propertyExample': (_) => const PropertyExample(),
        // Add more routes as needed
      },
    );
  }
}
