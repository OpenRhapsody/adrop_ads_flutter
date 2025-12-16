import 'dart:io';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:adrop_ads_flutter_example/utils/error_utils.dart';
import 'package:flutter/material.dart';

/// Banner Ad Example
///
/// This example demonstrates how to integrate and display banner ads
/// using the Adrop Ads SDK in Flutter.
class BannerExample extends StatefulWidget {
  const BannerExample({super.key});

  @override
  State createState() => _BannerExampleState();
}

class _BannerExampleState extends State<BannerExample> {
  static const double _horizontalPadding = 16;
  static const double bannerHeight = 80;

  bool isLoaded = false;
  AdropErrorCode? errorCode;
  AdropErrorCode? emptyErrorCode;

  late AdropBannerView bannerView;
  late AdropBannerView emptyBannerView;

  /// Returns the ad unit ID for the current platform
  /// Replace with your actual ad unit ID from Adrop Console
  String unit() {
    return Platform.isAndroid ? testUnitId_80 : testUnitId_80;
  }

  @override
  void initState() {
    super.initState();

    // Create AdropBannerView with unit ID and listener
    bannerView = AdropBannerView(
      unitId: unit(),
      listener: AdropBannerListener(
        // Callback: Called when the ad is successfully received
        onAdReceived: (unitId, metadata) {
          debugPrint(
              "ad received $unitId, $metadata ${bannerView.creativeSize?.width}x${bannerView.creativeSize?.height}");
          setState(() {
            isLoaded = true;
            errorCode = null;
          });
        },
        // Callback: Called when the ad is clicked
        onAdClicked: (unitId, metadata) {
          debugPrint("ad clicked $unitId, $metadata");
        },
        // Callback: Called when the ad impression is recorded
        onAdImpression: (unitId, metadata) {
          debugPrint("ad impressed $unitId, $metadata");
        },
        // Callback: Called when the ad fails to load
        onAdFailedToReceive: (unitId, error) {
          debugPrint("ad onAdFailedToReceive $unitId, $error");
          setState(() {
            isLoaded = false;
            errorCode = error;
          });
        },
      ),
    );

    // Set banner ad size after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bannerView.adSize = Size(
          MediaQuery.of(context).size.width - _horizontalPadding * 2,
          bannerHeight);
    });

    // Example: Banner view with empty/invalid unit ID to demonstrate error handling
    emptyBannerView = AdropBannerView(
        unitId: testUnitId,
        listener: AdropBannerListener(
          onAdReceived: (unitId, metadata) {
            debugPrint("ad received $unitId $metadata");
          },
          onAdFailedToReceive: (unitId, error) {
            debugPrint("ad onAdFailedToReceive $unitId, $error");
            setState(() {
              emptyErrorCode = error;
            });
          },
        ));
  }

  /// Load banner ad with empty unit ID to test error callback
  void loadEmptyBanner() {
    setState(() {
      emptyErrorCode = null;
    });

    // Call load() to request an ad
    emptyBannerView.load();
  }

  void disposeAll() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          // Customizing the leading property to show a back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Navigates back when back button is pressed
            },
          ),
          title: const Text('Banner Example'),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 24,
                ),
                // Button to load the banner ad - calls bannerView.load()
                TextButton(
                    onPressed: bannerView.load,
                    child: const Text('load banner! (test ad)')),
                const Text(
                  'load banner, you can be received ad successfully when click load button',
                  textAlign: TextAlign.center,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: bannerHeight,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: isLoaded ? bannerView : Container(),
                ),
                errorDescription(),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 1,
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(vertical: 16),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextButton(
                    onPressed: loadEmptyBanner,
                    child: const Text('load banner! (empty ad)')),
                const Text(
                    'load banner, you can be received error callback when click load button',
                    textAlign: TextAlign.center),
                const SizedBox(
                  height: 24,
                ),
                emptyErrorDescription(),
              ],
            ),
          ),
        ));
  }

  Widget errorDescription() {
    if (errorCode == null) return Container();

    return Column(
      children: [
        Text('Error code: $errorCode'),
        Text(
          ErrorUtils.descriptionOf(errorCode),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget emptyErrorDescription() {
    if (emptyErrorCode == null) return Container();

    return Column(
      children: [
        Text('Error code: $emptyErrorCode'),
        Text(
          ErrorUtils.descriptionOf(emptyErrorCode),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  /// Dispose banner views when the widget is removed from the tree
  /// Always dispose AdropBannerView to prevent memory leaks
  @override
  void dispose() {
    super.dispose();
    bannerView.dispose();
    emptyBannerView.dispose();
  }
}
