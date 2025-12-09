import 'dart:io';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:adrop_ads_flutter_example/utils/error_utils.dart';
import 'package:flutter/material.dart';

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

  String unit() {
    // Use your actual banner ad unit IDs here
    return Platform.isAndroid ? testUnitId_80 : testUnitId_80;
  }

  @override
  void initState() {
    super.initState();

    bannerView = AdropBannerView(
      unitId: unit(),
      listener: AdropBannerListener(
        onAdReceived: (unitId, metadata) {
          debugPrint(
              "ad received $unitId, $metadata ${bannerView.creativeSize?.width}x${bannerView.creativeSize?.height}");
          setState(() {
            isLoaded = true;
            errorCode = null;
          });
        },
        onAdClicked: (unitId, metadata) {
          debugPrint("ad clicked $unitId, $metadata");
        },
        onAdImpression: (unitId, metadata) {
          debugPrint("ad impressed $unitId, $metadata");
        },
        onAdFailedToReceive: (unitId, error) {
          debugPrint("ad onAdFailedToReceive $unitId, $error");
          setState(() {
            isLoaded = false;
            errorCode = error;
          });
        },
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bannerView.adSize = Size(
          MediaQuery.of(context).size.width - _horizontalPadding * 2,
          bannerHeight);
    });

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

  void loadEmptyBanner() {
    setState(() {
      emptyErrorCode = null;
    });

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

  @override
  void dispose() {
    super.dispose();
    bannerView.dispose();
    emptyBannerView.dispose();
  }
}
