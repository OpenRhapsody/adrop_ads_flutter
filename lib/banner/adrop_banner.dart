import 'package:adrop_ads_flutter/adrop_error_code.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner_container.dart';
import 'package:adrop_ads_flutter/banner/adrop_banner_size.dart';
import 'package:adrop_ads_flutter/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/model/call_create_banner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef AdropBannerCreatedCallback = void Function(AdropBannerController controller);

class AdropBanner extends StatelessWidget {
  final AdropBannerCreatedCallback onAdropBannerCreated;
  final String unitId;
  final AdropBannerSize adSize;

  final VoidCallback? onAdReceived;
  final VoidCallback? onAdClicked;
  final Function(AdropErrorCode code)? onAdFailedToReceive;

  const AdropBanner({
    super.key,
    required this.onAdropBannerCreated,
    required this.unitId,
    required this.adSize,
    this.onAdReceived,
    this.onAdClicked,
    this.onAdFailedToReceive,
  });

  @override
  Widget build(BuildContext context) {
    final creationParams = CallCreateBanner(unitId: unitId, adSize: adSize);

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
    onAdropBannerCreated(AdropBannerController.withId(
      id,
      onAdReceived: onAdReceived,
      onAdClicked: onAdClicked,
      onAdFailedToReceive: onAdFailedToReceive,
    ));
  }
}
