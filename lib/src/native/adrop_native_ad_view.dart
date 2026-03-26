import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:adrop_ads_flutter/src/model/call_create_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../adrop_ad.dart';
import 'adrop_native_ad_provider.dart';

/// AdropNativeAdView class responsible for displaying native ads to the user.
///
/// [ad] required AdropNativeAd
/// [child] required child widget
class AdropNativeAdView extends StatefulWidget {
  final Widget child;
  final AdropNativeAd? ad;

  const AdropNativeAdView({super.key, required this.ad, required this.child});

  @override
  State<AdropNativeAdView> createState() => _AdropNativeAdViewState();
}

class _AdropNativeAdViewState extends State<AdropNativeAdView> {
  Offset? _downPosition;

  AdropNativeAd? get ad => widget.ad;
  Widget get child => widget.child;

  @override
  Widget build(BuildContext context) {
    if (ad == null) return Container();

    var useCustomClick = ad?.useCustomClick ?? false;
    var isBackfilled = ad?.isBackfilled ?? false;
    final touchSlop = MediaQuery.of(context).devicePixelRatio * 8;
    // Disable IgnorePointer for backfill ads so native ad view (e.g. GADNativeAdView) receives touches directly
    var ignorePointer = useCustomClick && !isBackfilled;
    var platformView = Positioned.fill(
        child: IgnorePointer(ignoring: ignorePointer, child: _platformView()));
    var children = useCustomClick
        ? [
            platformView,
            if (!isBackfilled)
              Listener(
                behavior: HitTestBehavior.deferToChild,
                onPointerDown: (e) => _downPosition = e.position,
                onPointerUp: (e) {
                  final down = _downPosition;
                  _downPosition = null;
                  if (down == null) return;
                  if ((e.position - down).distance < touchSlop) {
                    const MethodChannel(AdropChannel.invokeChannel)
                        .invokeMethod(AdropMethod.performClick, {
                      "adType": AdType.native.name,
                      "requestId": ad?.requestId,
                    });
                  }
                },
                onPointerCancel: (_) => _downPosition = null,
                child: child,
              ),
            // Backfill: render child for display only, pass touches through to native ad view below
            if (isBackfilled) IgnorePointer(child: child),
          ]
        : [child, platformView];

    return AdropNativeAdProvider(
      ad: ad,
      child: Stack(
        children: children,
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
