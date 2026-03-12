import 'dart:math';

import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/adrop_error_code.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:adrop_ads_flutter/src/model/browser_target.dart';
import 'package:adrop_ads_flutter/src/model/creative_size.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_ad.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_event.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_listener.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_properties.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

final _random = Random.secure();

class MockAdropNativeAd extends Mock implements AdropNativeAd {
  static const MethodChannel _invokeChannel =
      MethodChannel(AdropChannel.invokeChannel);

  final String _unitId;
  @override
  final bool useCustomClick;
  @override
  final AdropNativeListener? listener;
  late final String _requestId;
  late final MethodChannel? _adropEventObserverChannel;

  String _creativeId = '';
  String _txId = '';
  String _campaignId = '';
  String _destinationURL = '';
  int? _browserTarget;
  bool _loaded = false;
  AdropNativeProperties _properties = AdropNativeProperties.from(null);
  CreativeSize _creativeSize = const CreativeSize(width: 0.0, height: 0.0);

  @override
  bool get isLoaded => _loaded;
  @override
  String get unitId => _unitId;
  @override
  String get creativeId => _creativeId;
  @override
  String get requestId => _requestId;
  @override
  String get txId => _txId;
  @override
  String get campaignId => _campaignId;
  @override
  String get destinationURL => _destinationURL;
  @override
  BrowserTarget? get browserTarget => BrowserTarget.fromOrdinal(_browserTarget);
  @override
  AdropNativeProperties get properties => _properties;
  @override
  bool get isBackfilled => _properties.isBackfilled;
  @override
  CreativeSize get creativeSize => _creativeSize;

  MockAdropNativeAd({
    required String unitId,
    this.useCustomClick = false,
    this.listener,
  }) : _unitId = unitId {
    _requestId = _getRequestId();

    if (listener != null) {
      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(AdType.native, _requestId);
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
    return await _invokeChannel.invokeMethod(AdropMethod.loadAd, {
      "adType": AdType.native.index,
      "unitId": unitId,
      "useCustomClick": useCustomClick,
      "requestId": _requestId,
    });
  }

  Future<void> _handleEvent(MethodCall call) async {
    if (listener == null) return;

    var args = call.arguments;
    final event = AdropNativeEvent.from(args);

    _creativeId = call.arguments['creativeId'] ?? '';
    _txId = call.arguments['txId'] ?? '';
    _campaignId = call.arguments['campaignId'] ?? '';
    _destinationURL = call.arguments['destinationURL'] ?? '';
    _browserTarget = call.arguments['browserTarget'];

    if (args != null &&
        args['creativeSizeWidth'] != null &&
        args['creativeSizeHeight'] != null) {
      _creativeSize = CreativeSize(
        width: args['creativeSizeWidth'],
        height: args['creativeSizeHeight'],
      );
    }

    switch (call.method) {
      case AdropMethod.didReceiveAd:
        _loaded = true;
        _properties = event.properties;
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
    }
  }
}
