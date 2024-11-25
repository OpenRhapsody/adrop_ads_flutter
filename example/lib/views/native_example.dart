import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:adrop_ads_flutter_example/utils/error_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NativeExample extends StatefulWidget {
  const NativeExample({Key? key}) : super(key: key);

  @override
  State createState() => _NativeExampleState();
}

class _NativeExampleState extends State<NativeExample> {
  bool isLoaded = false;
  bool isShown = false;
  AdropErrorCode? errorCode;
  AdropNativeAd? nativeAd;

  bool disabledReset() => !(errorCode != null || isShown);

  @override
  void initState() {
    super.initState();
    reset(testUnitIdNative);
  }

  void reset(String unitId) {
    nativeAd = AdropNativeAd(
        unitId: unitId,
        listener: AdropNativeListener(onAdReceived: (ad) {
          debugPrint("nativeAd received $unitId, ${ad.properties}");
          setState(() {
            isLoaded = true;
            errorCode = null;
          });
        }, onAdFailedToReceive: (_, error) {
          setState(() {
            debugPrint("nativeAd failed to receive $unitId, $errorCode");
            errorCode = error;
          });
        }, onAdClicked: (_) {
          debugPrint("nativeAd clicked $unitId");
        }));
    setState(() {
      isLoaded = false;
      isShown = false;
      errorCode = null;
    });
  }

  Widget nativeAdView(BuildContext context) {
    if (!isLoaded) return Container();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      width: MediaQuery.of(context).size.width,
      child: AdropNativeAdView(
        ad: nativeAd,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    nativeAd?.properties.profile?.displayLogo ?? '',
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    nativeAd?.properties.profile?.displayName ?? '',
                  )
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              if (nativeAd?.properties.headline != null)
                Text(
                  nativeAd?.properties.headline ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (nativeAd?.properties.body != null)
                Text(
                  nativeAd?.properties.body ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              if (nativeAd?.properties.asset != null)
                Column(children: [
                  const SizedBox(
                    height: 4,
                  ),
                  Image.network(
                    nativeAd?.properties.asset ?? '',
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const CupertinoActivityIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                  )
                ]),
              if (nativeAd?.properties.extra['sampleExtraId'] != null)
                Column(
                  children: [
                    const SizedBox(
                      height: 8,
                    ),
                    Text(
                      nativeAd?.properties.extra['sampleExtraId'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text('NativeAd Example'),
        ),
        body: SingleChildScrollView(
            child: SafeArea(
                child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: nativeAd?.load,
                          child: const Text('native ad load'),
                        ),
                        nativeAdView(context),
                        TextButton(
                            onPressed: disabledReset()
                                ? null
                                : () {
                                    reset(testUnitIdNative);
                                  },
                            child: const Text('reset (test ad)')),
                        const Text(
                          'Reset native ad, you can be received ad successfully when click load button',
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
                            'Reset native ad, you can be received error callback when click load button',
                            textAlign: TextAlign.center),
                        const SizedBox(
                          height: 24,
                        ),
                        errorDescription()
                      ],
                    )))));
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
}
