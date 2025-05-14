import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/utils/id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../bridge/adrop_channel.dart';
import '../model/call_create_ad.dart';
import 'adrop_ad_manager.dart';

class AdropBannerView extends StatelessWidget {
  final String unitId;

  final AdropBannerListener? listener;

  final String _requestId;

  /// Banner view class responsible for displaying banner ads to the user.
  ///
  /// [unitId] required Ad unit ID
  /// [listener] optional invoked when the banner received, failed to receive and clicked
  AdropBannerView({super.key, required this.unitId, this.listener}): _requestId = nanoid();

  @override
  Widget build(BuildContext context) {
    final creationParams = CallCreateAd(unitId: unitId, requestId: _requestId);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
            viewType: AdropChannel.bannerEventListenerChannel,
            creationParams: creationParams.toJson(),
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: (_) {});
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdropChannel.bannerEventListenerChannel,
          creationParams: creationParams.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (_) {},
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported');
    }
  }

  /// Requests an ad from Adrop using the Ad unit ID of the AdropBannerView.
  Future<void> load() async {
    return await adropAdManager.load(this, _requestId);
  }

  /// Invoked when dispose() is called on the corresponding AdropBannerView
  Future<void> dispose() async {
    return await adropAdManager.dispose(this, _requestId);
  }
}
