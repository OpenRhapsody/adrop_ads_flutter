import 'dart:io';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:flutter/material.dart';

import '../utils/error_utils.dart';

/// Rewarded Ad Example
///
/// This example demonstrates how to integrate and display rewarded ads
/// using the Adrop Ads SDK in Flutter. Users watch the ad and receive
/// rewards upon completion.
class RewardedExample extends StatefulWidget {
  const RewardedExample({super.key});

  @override
  State<StatefulWidget> createState() => _RewardedExampleState();
}

class _RewardedExampleState extends State<RewardedExample> {
  bool isLoaded = false;
  bool isShown = false;
  AdropErrorCode? errorCode;
  AdropRewardedAd? rewardedAd;

  bool disabledReset() => !(errorCode != null || isShown);

  /// Returns the ad unit ID for the current platform
  /// Replace with your actual ad unit ID from Adrop Console
  String unit() {
    return Platform.isAndroid ? testUnitIdRewardedAd : testUnitIdRewardedAd;
  }

  @override
  void initState() {
    super.initState();
    reset(unit());
  }

  /// Initialize or reset the rewarded ad instance
  void reset(String unitId) {
    // Dispose previous ad instance before creating a new one
    rewardedAd?.dispose();

    // Create AdropRewardedAd with unit ID and listener
    rewardedAd = AdropRewardedAd(
        unitId: unitId,
        listener: AdropRewardedListener(
          // Callback: Called when the ad is successfully loaded
          onAdReceived: (ad) {
            debugPrint(
                "rewardedAd received $unitId, ${ad.creativeId} ${ad.txId} ${ad.campaignId} browserTarget: ${ad.browserTarget}");
            setState(() {
              isLoaded = true;
              errorCode = null;
            });
          },
          // Callback: Called when the ad fails to load
          onAdFailedToReceive: (_, error) {
            setState(() {
              debugPrint("rewardedAd failed to receive $unitId, $errorCode");
              errorCode = error;
            });
          },
          // Callback: Called when the ad is clicked
          onAdClicked: (ad) {
            debugPrint(
                "rewardedAd clicked $unitId browserTarget: ${ad.browserTarget}");
          },
          // Callback: Called when the full-screen ad is presented
          onAdDidPresentFullScreen: (_) {
            debugPrint("rewardedAd did present full screen $unitId");
            setState(() {
              isShown = true;
              errorCode = null;
            });
          },
          // Callback: Called when the full-screen ad is dismissed
          onAdDidDismissFullScreen: (_) {
            debugPrint("rewardedAd did dismiss full screen $unitId");
          },
          // Callback: Called when the ad fails to show
          onAdFailedToShowFullScreen: (_, error) {
            debugPrint(
                "rewardedAd failed to show full screen $unitId, $errorCode");
            setState(() {
              errorCode = error;
            });
          },
          // Callback: Called when the user earns a reward after watching the ad
          // Implement your reward logic here (e.g., grant coins, unlock content)
          onAdEarnRewardHandler: (_, type, amount) {
            debugPrint("rewardedAd earn rewards: $unitId, $type, $amount");
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
          title: const Text('RewardedAd Example'),
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
                    // Button to load the rewarded ad - calls rewardedAd.load()
                    TextButton(
                      onPressed: rewardedAd?.load,
                      child: const Text('RewardedAd load'),
                    ),
                    // Button to show the ad - only enabled when ad is loaded
                    // calls rewardedAd.show()
                    TextButton(
                        onPressed: isLoaded ? rewardedAd?.show : null,
                        child: const Text('RewardedAd show')),
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
                      'Reset rewardedAd, you can be received ad successfully when click load button',
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
                        'Reset rewardedAd, you can be received error callback when click load button',
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

  /// Dispose rewarded ad when the widget is removed from the tree
  /// Always dispose AdropRewardedAd to prevent memory leaks
  @override
  void dispose() {
    super.dispose();
    rewardedAd?.dispose();
  }
}
