import 'dart:io';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:flutter/material.dart';

import '../utils/error_utils.dart';

/// Interstitial Ad Example
///
/// This example demonstrates how to integrate and display full-screen
/// interstitial ads using the Adrop Ads SDK in Flutter.
class InterstitialExample extends StatefulWidget {
  const InterstitialExample({super.key});

  @override
  State<StatefulWidget> createState() => _InterstitialExampleState();
}

class _InterstitialExampleState extends State<InterstitialExample> {
  bool isLoaded = false;
  bool isShown = false;
  AdropErrorCode? errorCode;
  AdropInterstitialAd? interstitialAd;

  bool disabledReset() => !(errorCode != null || isShown);

  /// Returns the ad unit ID for the current platform
  /// Replace with your actual ad unit ID from Adrop Console
  String unit() {
    return Platform.isAndroid
        ? testUnitIdInterstitialAd
        : testUnitIdInterstitialAd;
  }

  @override
  void initState() {
    super.initState();
    reset(unit());
  }

  /// Initialize or reset the interstitial ad instance
  void reset(String unitId) {
    // Dispose previous ad instance before creating a new one
    interstitialAd?.dispose();

    // Create AdropInterstitialAd with unit ID and listener
    interstitialAd = AdropInterstitialAd(
        unitId: unitId,
        listener: AdropInterstitialListener(
          // Callback: Called when the ad is successfully loaded
          onAdReceived: (ad) {
            debugPrint(
                "interstitialAd received $unitId, ${ad.creativeId} ${ad.txId} ${ad.campaignId} browserTarget: ${ad.browserTarget}");
            setState(() {
              isLoaded = true;
              errorCode = null;
            });
          },
          // Callback: Called when the ad fails to load
          onAdFailedToReceive: (_, error) {
            setState(() {
              debugPrint(
                  "interstitialAd failed to receive $unitId, $errorCode");
              errorCode = error;
            });
          },
          // Callback: Called when the ad is clicked
          onAdClicked: (ad) {
            debugPrint(
                "interstitialAd clicked $unitId browserTarget: ${ad.browserTarget}");
          },
          // Callback: Called when the full-screen ad is presented
          onAdDidPresentFullScreen: (_) {
            debugPrint("interstitialAd did present full screen $unitId");
            setState(() {
              isShown = true;
              errorCode = null;
            });
          },
          // Callback: Called when the full-screen ad is dismissed
          onAdDidDismissFullScreen: (_) {
            debugPrint("interstitialAd did dismiss full screen $unitId");
          },
          // Callback: Called when the ad fails to show
          onAdFailedToShowFullScreen: (_, error) {
            debugPrint(
                "interstitialAd failed to show full screen $unitId, $errorCode");
            setState(() {
              errorCode = error;
            });
          },
          // Callback: Called when the user presses the back button (Android only)
          onAdBackButtonPressed: (ad) {
            debugPrint("interstitialAd back button pressed $unitId");
            (ad as AdropInterstitialAd).close();
          },
        ));

    setState(() {
      isLoaded = false;
      isShown = false;
      errorCode = null;
    });
  }

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
          title: const Text('InterstitialAd Example'),
        ),
        body: SafeArea(
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 24,
                    ),
                    // Button to load the interstitial ad - calls interstitialAd.load()
                    TextButton(
                      onPressed: interstitialAd?.load,
                      child: const Text('interstitial load'),
                    ),
                    // Button to show the ad - only enabled when ad is loaded
                    // calls interstitialAd.show()
                    TextButton(
                        onPressed: isLoaded ? interstitialAd?.show : null,
                        child: const Text('interstitial show')),
                    const SizedBox(
                      height: 24,
                    ),
                    TextButton(
                        onPressed: disabledReset()
                            ? null
                            : () {
                                reset(unit());
                              },
                        child: const Text('reset (test ad)')),
                    const Text(
                      'Reset interstitialAd, you can be received ad successfully when click load button',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    TextButton(
                        onPressed: disabledReset()
                            ? null
                            : () {
                                reset(testUnitId);
                              },
                        child: const Text('reset (empty ad)')),
                    const Text(
                        'Reset interstitialAd, you can be received error callback when click load button',
                        textAlign: TextAlign.center),
                    const SizedBox(
                      height: 48,
                    ),
                    errorDescription()
                  ],
                ))));
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

  /// Dispose interstitial ad when the widget is removed from the tree
  /// Always dispose AdropInterstitialAd to prevent memory leaks
  @override
  void dispose() {
    super.dispose();
    interstitialAd?.dispose();
  }
}
