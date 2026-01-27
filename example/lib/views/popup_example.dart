import 'dart:io';
import 'dart:math';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

import '../test_unit_ids.dart';
import '../utils/error_utils.dart';

/// Popup Ad Example
///
/// This example demonstrates how to integrate and display popup ads
/// using the Adrop Ads SDK in Flutter. Popup ads can be positioned
/// at the center or bottom of the screen.
class PopupExample extends StatefulWidget {
  const PopupExample({super.key});

  @override
  State<StatefulWidget> createState() => _PopupExampleState();
}

class _PopupExampleState extends State<PopupExample> {
  bool isLoaded = false;
  bool isShown = false;
  AdropPopupAd? popupAd;
  AdropErrorCode? errorCode;

  bool disabledReset() => !(errorCode != null || isShown);

  /// Returns the center popup ad unit ID for the current platform
  /// Replace with your actual ad unit ID from Adrop Console
  String unitCenter() {
    return Platform.isAndroid
        ? testUnitIdPopupAdCenter
        : testUnitIdPopupAdCenter;
  }

  /// Returns the bottom popup ad unit ID for the current platform
  /// Replace with your actual ad unit ID from Adrop Console
  String unitBottom() {
    return Platform.isAndroid
        ? testUnitIdPopupAdBottom
        : testUnitIdPopupAdBottom;
  }

  @override
  void initState() {
    super.initState();
    reset(testUnitIdPopupAdBottom);
  }

  Color getRandomColor() {
    Random random = Random();
    int r = random.nextInt(256);
    int g = random.nextInt(256);
    int b = random.nextInt(256);
    return Color.fromRGBO(r, g, b, 1);
  }

  /// Initialize or reset the popup ad instance
  void reset(String uniId) {
    // Dispose previous ad instance before creating a new one
    popupAd?.dispose();

    // Create AdropPopupAd with unit ID, listener, and optional background color
    popupAd = AdropPopupAd(
      unitId: uniId,
      listener: AdropPopupListener(
        // Callback: Called when the ad is successfully loaded
        onAdReceived: (ad) {
          debugPrint(
              "PopupAd received ${ad.unitId} browserTarget: ${ad.browserTarget}");
          setState(() {
            isLoaded = true;
            errorCode = null;
          });
        },
        // Callback: Called when the full-screen ad is dismissed
        onAdDidDismissFullScreen: (ad) {
          setState(() {
            isShown = true;
          });
        },
        // Callback: Called when the ad fails to load
        onAdFailedToReceive: (_, errorCode) {
          debugPrint("PopupAd failed to receive $errorCode");
          setState(() {
            this.errorCode = errorCode;
          });
        },
        // Callback: Called when the ad fails to show
        onAdFailedToShowFullScreen: (_, errorCode) {
          debugPrint("PopupAd failed to show full screen $errorCode");
          setState(() {
            this.errorCode = errorCode;
          });
        },
        // Callback: Called when the ad impression is recorded
        onAdImpression: (ad) {
          debugPrint(
              "PopupAd impression ${ad.creativeId} ${ad.txId} ${ad.campaignId} ${ad.destinationURL} browserTarget: ${ad.browserTarget}");
        },
      ),
      // Optional: Set custom background color for the popup
      backgroundColor: getRandomColor(),
    );

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
          title: const Text('PopupAd Example'),
        ),
        body: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 24,
                ),
                // Button to load the popup ad - calls popupAd.load()
                TextButton(
                  onPressed: popupAd?.load,
                  child: const Text('popup ad load'),
                ),
                // Button to show the ad - only enabled when ad is loaded
                // calls popupAd.show()
                TextButton(
                  onPressed: isLoaded ? popupAd?.show : null,
                  child: const Text('popup ad show'),
                ),
                TextButton(
                    onPressed: disabledReset()
                        ? null
                        : () {
                            reset(unitBottom());
                          },
                    child: const Text('reset (test ad)')),
                const Text(
                  'Reset popup ad (bottom), you can be received ad successfully when click load button',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                    onPressed: disabledReset()
                        ? null
                        : () {
                            reset(unitCenter());
                          },
                    child: const Text('reset (test ad)')),
                const Text(
                  'Reset popup ad (center), you can be received ad successfully when click load button',
                  textAlign: TextAlign.center,
                ),
                TextButton(
                    onPressed: disabledReset()
                        ? null
                        : () {
                            reset(testUnitId);
                          },
                    child: const Text('reset (empty ad)')),
                const Text(
                  'Reset popup ad, you can be received error callback when click load button',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 48,
                ),
                errorDescription(),
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

  /// Dispose popup ad when the widget is removed from the tree
  /// Always dispose AdropPopupAd to prevent memory leaks
  @override
  void dispose() {
    super.dispose();
    popupAd?.dispose();
  }
}
