import 'dart:math';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

import '../test_unit_ids.dart';
import '../utils/error_utils.dart';

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

  void reset(String uniId) {
    popupAd?.dispose();
    popupAd = AdropPopupAd(
      unitId: uniId,
      listener: AdropPopupListener(onAdReceived: (ad) {
        debugPrint("PopupAd received");
        setState(() {
          isLoaded = true;
          errorCode = null;
        });
      }, onAdDidDismissFullScreen: (ad) {
        setState(() {
          isShown = true;
        });
      }, onAdFailedToReceive: (_, errorCode) {
        debugPrint("PopupAd failed to receive $errorCode");
        setState(() {
          this.errorCode = errorCode;
        });
      }, onAdFailedToShowFullScreen: (_, errorCode) {
        debugPrint("PopupAd failed to show full screen $errorCode");
        setState(() {
          this.errorCode = errorCode;
        });
      }),
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
              Navigator.of(context).pop(); // Navigates back when back button is pressed
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
                TextButton(
                  onPressed: popupAd?.load,
                  child: const Text('popup ad load'),
                ),
                TextButton(
                  onPressed: isLoaded ? popupAd?.show : null,
                  child: const Text('popup ad show'),
                ),
                TextButton(
                    onPressed: disabledReset()
                        ? null
                        : () {
                            reset(testUnitIdPopupAdBottom);
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
                            reset(testUnitIdPopupAdCenter);
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

  @override
  void dispose() {
    super.dispose();
    popupAd?.dispose();
  }
}
