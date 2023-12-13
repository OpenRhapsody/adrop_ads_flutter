import 'dart:async';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';

import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
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
  bool isLoaded = false;
  AdropBannerView? bannerView;

  @override
  void initState() {
    super.initState();
    initialize();

    _loadAd();
  }

  Future<void> initialize() async {
    var production = false; // TODO set true for production mode
    await Adrop.initialize(production);
  }

  void _loadAd() {
    bannerView ??= AdropBannerView(
      unitId: getUnitId(),
      listener: AdropBannerListener(
        onAdReceived: (unitId) {
          debugPrint("ad received $unitId");
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToReceive: (unitId, error) {
          debugPrint("ad onAdFailedToReceive $unitId, $error");
          setState(() {
            isLoaded = false;
          });
        },
      ),
    );
    bannerView?.load();
  }

  String getUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return testUnitId_50;
      case TargetPlatform.iOS:
        return testUnitId_80;
      default:
        return "";
    }
  }

  double adSize() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 50;
      case TargetPlatform.iOS:
        return 80;
      default:
        return 0;
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
              TextButton(onPressed: _loadAd, child: const Text('Reload Ad!')),
              TextButton(
                  onPressed: () {
                    bannerView?.dispose();
                    setState(() {
                      bannerView = null;
                      isLoaded = false;
                    });
                  },
                  child: const Text('dispose')),
              const Spacer(),
              bannerView != null && isLoaded
                  ? SizedBox(
                      width: screenWidth,
                      height: adSize(),
                      child: bannerView,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    bannerView?.dispose();
    bannerView = null;
  }
}
