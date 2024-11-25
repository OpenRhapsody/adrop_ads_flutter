import 'package:adrop_ads_flutter/src/model/call_create_ad.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../adrop_error_code.dart';
import '../bridge/adrop_channel.dart';
import 'adrop_banner_controller.dart';

typedef AdropBannerCreatedCallback = void Function(
    AdropBannerController controller);

class AdropBanner extends StatelessWidget {
  final String unitId;

  final AdropBannerCreatedCallback _onAdropBannerCreated;
  final void Function(AdropBanner banner)? _onAdReceived;
  final void Function(AdropBanner banner)? _onAdClicked;
  final void Function(AdropBanner banner, AdropErrorCode errorCode)?
      _onAdFailedToReceive;

  @Deprecated("use AdropBannerView, AdropManager")

  /// Banner view class responsible for displaying banner ads to the user.
  ///
  /// [unitId] required Ad unit ID
  /// [onAdropBannerCreated] required callback controller
  /// [onAdReceived] optional invoked when the banner receives an ad.
  /// [onAdClicked] optional invoked when the AdropBanner is clicked.
  /// [onAdFailedToReceive] optional invoked when the banner fails to receive an ad.
  const AdropBanner({
    super.key,
    required this.unitId,
    required void Function(AdropBannerController) onAdropBannerCreated,
    void Function(AdropBanner)? onAdReceived,
    void Function(AdropBanner)? onAdClicked,
    void Function(AdropBanner, AdropErrorCode)? onAdFailedToReceive,
  })  : _onAdropBannerCreated = onAdropBannerCreated,
        _onAdFailedToReceive = onAdFailedToReceive,
        _onAdClicked = onAdClicked,
        _onAdReceived = onAdReceived;

  @override
  Widget build(BuildContext context) {
    final creationParams = CallCreateAd(unitId: unitId);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: AdropChannel.bannerEventListenerChannel,
          creationParams: creationParams.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdropChannel.bannerEventListenerChannel,
          creationParams: creationParams.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported');
    }
  }

  void _onPlatformViewCreated(int id) {
    _onAdropBannerCreated(AdropBannerController.withId(
      id,
      banner: this,
      onAdReceived: _onAdReceived,
      onAdClicked: _onAdClicked,
      onAdFailedToReceive: _onAdFailedToReceive,
    ));
  }
}
