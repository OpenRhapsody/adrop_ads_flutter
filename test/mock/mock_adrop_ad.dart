import 'dart:math';

import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/adrop_error_code.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'mock_adrop_navigator_observer.dart';

final _random = Random.secure();

class MockAdropAd extends Mock implements AdropAd {
  static const MethodChannel _invokeChannel =
      MethodChannel(AdropChannel.invokeChannel);

  final AdType _adType;
  final String _unitId;
  bool _loaded;
  late final String _requestId;
  @override
  final AdropAdListener? listener;
  late final MethodChannel? _adropEventObserverChannel;

  @override
  bool get isLoaded => _loaded;
  @override
  String get unitId => _unitId;
  String get requestId => _requestId;

  MockAdropAd({required AdType adType, required String unitId, this.listener})
      : _adType = adType,
        _unitId = unitId,
        _loaded = false {
    _requestId = _getRequestId();

    if (listener != null) {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(_adType, _requestId);
      _adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      if (_adropEventObserverChannel != null) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
                _adropEventObserverChannel!, _handleEvent);
      }
    }
  }

  String _getRequestId() {
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const len = alphabet.length;
    int size = 21;

    String id = '';
    while (0 < size--) {
      id += alphabet[_random.nextInt(len)];
    }
    return id;
  }

  @override
  Future<void> load() async {
    return await _invokeChannel.invokeMethod(AdropMethod.loadAd,
        {"adType": _adType.index, "unitId": unitId, "requestId": _requestId});
  }

  @override
  Future<void> show() async {
    return _invokeChannel.invokeMethod(
        AdropMethod.showAd, {"adType": _adType.index, "requestId": _requestId});
  }

  @override
  Future<void> dispose() async {
    return await _invokeChannel.invokeMethod(AdropMethod.disposeAd,
        {"adType": _adType.index, "requestId": _requestId});
  }

  Future<void> _handleEvent(MethodCall call) async {
    if (listener == null) return;

    final event = AdropEvent.from(call.arguments);

    switch (call.method) {
      case AdropMethod.didReceiveAd:
        _loaded = true;
        listener!.onAdReceived?.call(this);
        break;
      case AdropMethod.didClickAd:
        listener!.onAdClicked?.call(this);
        break;
      case AdropMethod.didFailToReceiveAd:
        listener!.onAdFailedToReceive
            ?.call(this, event.errorCode ?? AdropErrorCode.undefined);
        break;
      case AdropMethod.didImpression:
        _invokeAttach();
        listener!.onAdImpression?.call(this);
        break;
      case AdropMethod.willDismissFullScreen:
        listener!.onAdWillDismissFullScreen?.call(this);
        break;
      case AdropMethod.didDismissFullScreen:
        listener!.onAdDidDismissFullScreen?.call(this);
        break;
      case AdropMethod.willPresentFullScreen:
        listener!.onAdWillPresentFullScreen?.call(this);
        break;
      case AdropMethod.didPresentFullScreen:
        listener!.onAdDidPresentFullScreen?.call(this);
        break;
      case AdropMethod.didFailedToShowFullScreen:
        listener!.onAdFailedToShowFullScreen
            ?.call(this, event.errorCode ?? AdropErrorCode.undefined);
        break;
      case AdropMethod.didHandleEarnReward:
        listener!.onAdEarnRewardHandler
            ?.call(this, event.type ?? 0, event.amount ?? 0);
        break;
    }
  }

  void _invokeAttach() {
    const MethodChannel(AdropChannel.invokeChannel).invokeMethod(
        AdropMethod.pageAttach,
        {"unitId": unitId, "page": MockAdropNavigatorObserver.last()});
  }
}
