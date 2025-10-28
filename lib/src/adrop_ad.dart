import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/utils/id.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bridge/adrop_method.dart';

enum AdType { undefined, interstitial, rewarded, popup, native }

class AdropEvent {
  final String unitId;
  final String method;
  AdropErrorCode? errorCode;
  int? type;
  int? amount;

  AdropEvent.from(dynamic arguments)
      : unitId = arguments != null ? arguments['unitId'] ?? '' : '',
        method = arguments != null ? arguments['method'] ?? '' : '',
        errorCode = arguments != null && arguments['errorCode'] != null
            ? AdropErrorCode.getByCode(arguments['errorCode'])
            : null,
        type = arguments != null ? arguments['type'] : null,
        amount = arguments != null ? arguments['amount'] : null;
}

class AdropAdListener {
  final AdropAdCallback? onAdReceived;
  final AdropAdCallback? onAdClicked;
  final AdropAdCallback? onAdImpression;
  final AdropAdCallback? onAdWillPresentFullScreen;
  final AdropAdCallback? onAdDidPresentFullScreen;
  final AdropAdCallback? onAdWillDismissFullScreen;
  final AdropAdCallback? onAdDidDismissFullScreen;
  final AdropAdErrorCallback? onAdFailedToReceive;
  final AdropAdErrorCallback? onAdFailedToShowFullScreen;
  final AdropAdRewardEventCallback? onAdEarnRewardHandler;

  AdropAdListener({
    this.onAdReceived,
    this.onAdClicked,
    this.onAdImpression,
    this.onAdFailedToReceive,
    this.onAdDidPresentFullScreen,
    this.onAdWillPresentFullScreen,
    this.onAdDidDismissFullScreen,
    this.onAdWillDismissFullScreen,
    this.onAdFailedToShowFullScreen,
    this.onAdEarnRewardHandler,
  });
}

abstract class AdropAd {
  static const MethodChannel _invokeChannel =
      MethodChannel(AdropChannel.invokeChannel);

  final AdType _adType;
  final String _unitId;
  String _creativeId = '';
  String _txId = '';
  String _destinationURL = '';
  String _campaignId = '';
  bool _loaded;
  final AdropAdListener? listener;
  late final String _requestId;
  late final MethodChannel? _adropEventObserverChannel;

  /// Returns `true` if an Adrop ad is loaded.
  bool get isLoaded => _loaded;

  /// Returns an Adrop ad's unitId.
  String get unitId => _unitId;

  AdropAd({required AdType adType, required String unitId, this.listener})
      : _adType = adType,
        _unitId = unitId,
        _loaded = false {
    _requestId = nanoid();

    if (listener != null) {
      final adropEventObserverChannelName = _getChannel();
      if (adropEventObserverChannelName == null) {
        debugPrint('adrop event observer is null');
      } else {
        _adropEventObserverChannel =
            MethodChannel(adropEventObserverChannelName);
        _adropEventObserverChannel?.setMethodCallHandler(_handleEvent);
      }
    }
  }

  String? _getChannel() {
    return AdropChannel.adropEventListenerChannelOf(_adType, _requestId);
  }

  /// Returns an Adrop ad's creativeId.
  String get creativeId {
    return _creativeId;
  }

  /// Returns an Adrop ad's transaction id.
  String get txId {
    return _txId;
  }

  /// Returns an Adrop ad's campaign id.
  String get campaignId {
    return _campaignId;
  }

  /// Returns an Adrop ad's destination url.
  String get destinationURL {
    return _destinationURL;
  }

  /// Requests an ad from Adrop using the Ad unit ID of the Adrop ad.
  Future<void> load() async {
    return await _invokeChannel.invokeMethod(AdropMethod.loadAd,
        {"adType": _adType.index, "unitId": unitId, "requestId": _requestId});
  }

  /// Requests to show an ad from Adrop using the Ad unit ID of the Adrop ad.
  Future<void> show() async {
    return _invokeChannel.invokeMethod(
        AdropMethod.showAd, {"adType": _adType.index, "requestId": _requestId});
  }

  /// Requests to customize a popup ad.
  @protected
  Future<void> customize([dynamic data]) async {
    return _invokeChannel.invokeMethod(AdropMethod.customizeAd,
        {"adType": _adType.index, "requestId": _requestId, "data": data});
  }

  /// Requests to close a popup ad.
  @protected
  Future<void> closeAd() async {
    return _invokeChannel.invokeMethod(AdropMethod.closeAd,
        {"adType": _adType.index, "requestId": _requestId});
  }

  /// Dispose the Adrop ad to free resources.
  Future<void> dispose() async {
    return await _invokeChannel.invokeMethod(AdropMethod.disposeAd,
        {"adType": _adType.index, "requestId": _requestId});
  }

  Future<void> _handleEvent(MethodCall call) async {
    if (listener == null) return;

    final event = AdropEvent.from(call.arguments);
    if (event.method != AdropMethod.didHandleEarnReward) {
      _creativeId = call.arguments['creativeId'] ?? '';
      _txId = call.arguments['txId'] ?? '';
      _campaignId = call.arguments['campaignId'] ?? '';
      _destinationURL = call.arguments['destinationURL'] ?? '';
    }

    switch (call.method) {
      case AdropMethod.didReceiveAd:
        _loaded = true;
        listener?.onAdReceived?.call(this);
        break;
      case AdropMethod.didClickAd:
        listener?.onAdClicked?.call(this);
        break;
      case AdropMethod.didFailToReceiveAd:
        listener?.onAdFailedToReceive
            ?.call(this, event.errorCode ?? AdropErrorCode.undefined);
        break;
      case AdropMethod.didImpression:
        listener?.onAdImpression?.call(this);
        break;
      case AdropMethod.willDismissFullScreen:
        listener?.onAdWillDismissFullScreen?.call(this);
        break;
      case AdropMethod.didDismissFullScreen:
        listener?.onAdDidDismissFullScreen?.call(this);
        break;
      case AdropMethod.willPresentFullScreen:
        listener?.onAdWillPresentFullScreen?.call(this);
        break;
      case AdropMethod.didPresentFullScreen:
        listener?.onAdDidPresentFullScreen?.call(this);
        break;
      case AdropMethod.didFailedToShowFullScreen:
        listener?.onAdFailedToShowFullScreen
            ?.call(this, event.errorCode ?? AdropErrorCode.undefined);
        break;
      case AdropMethod.didHandleEarnReward:
        listener?.onAdEarnRewardHandler
            ?.call(this, event.type ?? 0, event.amount ?? 0);
        break;
    }
  }
}
