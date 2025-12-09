import 'dart:io';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter_example/test_unit_ids.dart';
import 'package:adrop_ads_flutter_example/utils/error_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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
  late final WebViewController webViewController;
  bool isWebviewUsed = true;

  bool disabledReset() => !(errorCode != null || isLoaded);

  String unit() {
    // Use your actual native ad unit IDs here
    return Platform.isAndroid ? testUnitIdNative : testUnitIdNative;
  }

  @override
  void initState() {
    super.initState();

    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Handle the URL in Flutter instead of navigating
            if (request.url != 'about:blank' &&
                !request.url.contains('data:')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    reset(unit());
  }

  void reset(String unitId) {
    nativeAd = AdropNativeAd(
        unitId: unitId,
        useCustomClick:
            true, // set to true when using video creative or handling custom click
        listener: AdropNativeListener(onAdReceived: (ad) {
          debugPrint(
              'nativeAd received $unitId, ${ad.creativeId} ${ad.txId} ${ad.campaignId} ${ad.creativeSize.width}x${ad.creativeSize.height}');
          debugPrint('nativeAd properties: ${ad.properties.creative}');
          webViewController.loadHtmlString(ad.properties.creative ?? '');

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
        }, onAdImpression: (_) {
          debugPrint("nativeAd impressed $unitId");
        }));

    setState(() {
      isLoaded = false;
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
                  InkWell(
                    onTap: () {
                      debugPrint('Profile logo tapped');
                    },
                    child: Image.network(
                      nativeAd?.properties.profile?.displayLogo ?? '',
                      width: 24,
                      height: 24,
                    ),
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
                InkWell(
                  onTap: () {
                    debugPrint('Headline tapped');
                  },
                  child: Text(
                    nativeAd?.properties.headline ?? '',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (nativeAd?.properties.body != null)
                Text(
                  nativeAd?.properties.body ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              Column(children: [
                const SizedBox(
                  height: 4,
                ),
                creativeView(context),
              ]),
              if (nativeAd?.properties.callToAction != null &&
                  nativeAd!.properties.callToAction!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      debugPrint('CallToAction tapped');
                    },
                    child: Text(nativeAd?.properties.callToAction ?? ''),
                  ),
                ),
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

  Widget creativeView(BuildContext context) {
    if (!isLoaded) return Container();

    if (nativeAd?.isBackfilled == true) {
      return Image.network(
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
      );
    } else if (isWebviewUsed && nativeAd?.properties.creative != null) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Platform.isIOS ? 420 : 330,
        child: InkWell(
          onTap: () {
            debugPrint('Creative tapped');
          },
          onLongPress: () {
            debugPrint('Creative long pressed');
          },
          // child: IgnorePointer(
          child: WebViewWidget(controller: webViewController),
          // ),
        ),
      );
    } else {
      return Container();
    }
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
                                    reset(unit());
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
