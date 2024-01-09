import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:flutter/material.dart';

import '../utils/error_utils.dart';

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

  @override
  void initState() {
    super.initState();
    reset(testUnitIdInterstitialAd);
  }

  void reset(String unitId) {
    interstitialAd = AdropInterstitialAd(
        unitId: unitId,
        listener: AdropInterstitialListener(onAdReceived: (_) {
          debugPrint("interstitialAd received $unitId");
          setState(() {
            isLoaded = true;
            errorCode = null;
          });
        }, onAdFailedToReceive: (_, error) {
          setState(() {
            debugPrint("interstitialAd failed to receive $unitId, $errorCode");
            errorCode = error;
          });
        }, onAdClicked: (_) {
          debugPrint("interstitialAd clicked $unitId");
        }, onAdDidPresentFullScreen: (_) {
          debugPrint("interstitialAd did present full screen $unitId");
          setState(() {
            isShown = true;
            errorCode = null;
          });
        }, onAdDidDismissFullScreen: (_) {
          debugPrint("interstitialAd did dismiss full screen $unitId");
        }, onAdFailedToShowFullScreen: (_, error) {
          debugPrint("interstitialAd failed to show full screen $unitId, $errorCode");
          setState(() {
            errorCode = error;
          });
        }));
    setState(() {
      isLoaded = false;
      isShown = false;
      errorCode = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("interstitial errorCode $errorCode");
    return Scaffold(
        appBar: AppBar(
          // Customizing the leading property to show a back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(); // Navigates back when back button is pressed
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
                    TextButton(
                      onPressed: interstitialAd?.load,
                      child: const Text('interstitial load'),
                    ),
                    TextButton(
                        onPressed: isLoaded ? interstitialAd?.show : null, child: const Text('interstitial show')),
                    const SizedBox(
                      height: 24,
                    ),
                    TextButton(
                        onPressed: disabledReset()
                            ? null
                            : () {
                                reset(testUnitIdInterstitialAd);
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
                    const Text('Reset interstitialAd, you can be received error callback when click load button',
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
      children: [Text('Error code: $errorCode'), Text(ErrorUtils.descriptionOf(errorCode))],
    );
  }

  @override
  void dispose() {
    super.dispose();
    interstitialAd?.dispose();
  }
}
