import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/model/call_create_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adrop_native_ad_provider.dart';

/// AdropNativeAdView class responsible for displaying native ads to the user.
///
/// [ad] required AdropNativeAd
/// [child] required child widget
class AdropNativeAdView extends StatelessWidget {
  final Widget child;
  final AdropNativeAd? ad;

  const AdropNativeAdView({super.key, required this.ad, required this.child});

  @override
  Widget build(BuildContext context) {
    if (ad == null) return Container();

    return AdropNativeAdProvider(
      ad: ad,
      child: Stack(
        children: [
          child,
          Positioned.fill(child: _platformView()),
        ],
      ),
    );
  }

  Widget _platformView() {
    var requestId = ad?.requestId ?? '';
    if (requestId.isEmpty) return Container();

    final params = CallCreateAd(requestId: requestId);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
            viewType: AdropChannel.nativeEventListenerChannel,
            creationParams: params.toJson(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (_) {});
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdropChannel.nativeEventListenerChannel,
          creationParams: params.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (_) {},
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported');
    }
  }
}
