import 'package:adrop_ads_flutter/adrop_error_code.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner_container.dart';
import 'package:adrop_ads_flutter/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/model/call_create_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef AdropBannerCreatedCallback = void Function(AdropBannerController controller);

class AdropBanner extends StatelessWidget {
  final String unitId;

  final AdropBannerCreatedCallback _onAdropBannerCreated;
  final void Function(AdropBanner banner)? _onAdReceived;
  final void Function(AdropBanner banner)? _onAdClicked;
  final void Function(AdropBanner banner, AdropErrorCode code)? _onAdFailedToReceive;

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
    final creationParams = CallCreateBanner(unitId: unitId);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: AdropChannel.methodBannerChannel,
          creationParams: creationParams.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdropChannel.methodBannerChannel,
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
