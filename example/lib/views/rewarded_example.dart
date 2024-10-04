import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:flutter/material.dart';

import '../utils/error_utils.dart';

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

  @override
  void initState() {
    super.initState();
    reset(testUnitIdRewardedAd);
  }

  void reset(String unitId) {
    rewardedAd?.dispose();
    rewardedAd = AdropRewardedAd(
        unitId: unitId,
        listener: AdropRewardedListener(onAdReceived: (ad) {
          debugPrint(
              "rewardedAd received $unitId, ${(ad as AdropRewardedAd).creativeId}");
          setState(() {
            isLoaded = true;
            errorCode = null;
          });
        }, onAdFailedToReceive: (_, error) {
          setState(() {
            debugPrint("rewardedAd failed to receive $unitId, $errorCode");
            errorCode = error;
          });
        }, onAdClicked: (_) {
          debugPrint("rewardedAd clicked $unitId");
        }, onAdDidPresentFullScreen: (_) {
          debugPrint("rewardedAd did present full screen $unitId");
          setState(() {
            isShown = true;
            errorCode = null;
          });
        }, onAdDidDismissFullScreen: (_) {
          debugPrint("rewardedAd did dismiss full screen $unitId");
        }, onAdFailedToShowFullScreen: (_, error) {
          debugPrint(
              "rewardedAd failed to show full screen $unitId, $errorCode");
          setState(() {
            errorCode = error;
          });
        }, onAdEarnRewardHandler: (_, type, amount) {
          debugPrint("rewardedAd earn rewards: $unitId, $type, $amount");
        }));
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
                    TextButton(
                      onPressed: rewardedAd?.load,
                      child: const Text('RewardedAd load'),
                    ),
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
                                reset(testUnitIdRewardedAd);
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

  @override
  void dispose() {
    super.dispose();
    rewardedAd?.dispose();
  }
}
