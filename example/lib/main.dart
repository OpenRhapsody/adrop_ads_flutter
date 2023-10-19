import 'dart:async';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner_container.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AdropBannerController _bannerController;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initialize() async {
    await AdropAdsFlutter.initialize(true);
  }

  void _onAdropBannerCreated(AdropBannerController controller) {
    _bannerController = controller;
  }

  String getUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "01HCY55BZFNVX396GRZ8BYQNHD";
      case TargetPlatform.iOS:
        return "01HCY55BZFNVX396GRZ8BYQNHD";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello, Adrop Ads!'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              TextButton(
                  onPressed: () {
                    _bannerController.load();
                  },
                  child: const Text('Request Ad!')),
              const Spacer(),
              SizedBox(
                width: screenWidth,
                height: 80,
                child: AdropBanner(
                  onAdropBannerCreated: _onAdropBannerCreated,
                  unitId: getUnitId(),
                  adSize: AdropBannerSize.h80,
                  onAdClicked: () {
                    print("onAdClicked");
                  },
                  onAdReceived: () {
                    print("onAdReceived");
                  },
                  onAdFailedToReceive: (code) {
                    print("onAdFailedToReceive: $code");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
