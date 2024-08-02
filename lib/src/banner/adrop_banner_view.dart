import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../bridge/adrop_channel.dart';
import '../model/call_create_banner.dart';
import 'adrop_ad_manager.dart';

class AdropBannerView extends StatelessWidget {
  final String unitId;

  final AdropBannerListener? listener;

  /// Banner view class responsible for displaying banner ads to the user.
  ///
  /// [unitId] required Ad unit ID
  /// [listener] optional invoked when the banner received, failed to receive and clicked
  const AdropBannerView({super.key, required this.unitId, this.listener});

  @override
  Widget build(BuildContext context) {
    final creationParams = CallCreateBanner(unitId: unitId);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
            viewType: AdropChannel.bannerEventListenerChannel,
            creationParams: creationParams.toJson(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (_) {
              _attach();
            });
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdropChannel.bannerEventListenerChannel,
          creationParams: creationParams.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (_) {
            _attach();
          },
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported');
    }
  }

  /// Requests an ad from Adrop using the Ad unit ID of the AdropBannerView.
  Future<void> load() async {
    return await adropAdManager.load(this);
  }

  /// Invoked when dispose() is called on the corresponding AdropBannerView
  Future<void> dispose() async {
    return await adropAdManager.dispose(this);
  }

  Future<void> _attach() async {
    return await const MethodChannel(AdropChannel.invokeChannel).invokeMethod(
        AdropMethod.pageAttach,
        {"unitId": unitId, "page": AdropNavigatorObserver.last()});
  }
}
