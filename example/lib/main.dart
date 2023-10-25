import 'dart:async';

import 'package:adrop_ads_flutter/adrop.dart';
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

  Future<void> initialize() async {
    var production = false;  // TODO set true for production mode 
    await Adrop.initialize(production);
  }

  void _onAdropBannerCreated(AdropBannerController controller) {
    _bannerController = controller;
  }

  String getUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return "01HD5R49SJGY7KKEP9MK8DYEN7";
      case TargetPlatform.iOS:
        return "01HD5R54R6TDK91Y78M0J0SVCV";
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
                  onAdClicked: (banner) {
                    debugPrint("onAdClicked: ${banner.unitId}");
                  },
                  onAdReceived: (banner) {
                    debugPrint("onAdReceived: ${banner.unitId}");
                  },
                  onAdFailedToReceive: (banner, code) {
                    debugPrint("onAdFailedToReceive: ${banner.unitId} $code");
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
