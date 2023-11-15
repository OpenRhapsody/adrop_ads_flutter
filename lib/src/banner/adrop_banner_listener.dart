import '../adrop_error_code.dart';

typedef AdropAdEventCallback = void Function(String unitId);
typedef AdropAdFailedCallback = void Function(String unitId, AdropErrorCode error);

class AdropBannerListener {
  final AdropAdEventCallback? onAdReceived;
  final AdropAdEventCallback? onAdClicked;
  final AdropAdFailedCallback? onAdFailedToReceive;

  const AdropBannerListener({this.onAdReceived, this.onAdFailedToReceive, this.onAdClicked});
}
