import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/adrop_error_code.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:adrop_ads_flutter/src/model/creative_size.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_event.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_listener.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_properties.dart';
import 'package:adrop_ads_flutter/src/utils/id.dart';
import 'package:flutter/services.dart';

/// AdropNativeAd class responsible for requesting native ads.
///
/// [unitId] required Ad unit ID
/// [listener] optional invoked when a response from load method called back.
class AdropNativeAd {
  static const MethodChannel _invokeChannel =
      MethodChannel(AdropChannel.invokeChannel);

  final String _unitId;
  final AdropNativeListener? listener;
  late final String _requestId;
  late final MethodChannel? _adropEventObserverChannel;
  CreativeSize get creativeSize => _creativeSize;

  String _creativeId = '';
  bool _loaded;
  AdropNativeProperties _properties = AdropNativeProperties.from(null);
  CreativeSize _creativeSize = const CreativeSize(width: 0.0, height: 0.0);

  AdropNativeAd({
    required String unitId,
    this.listener,
  })  : _unitId = unitId,
        _loaded = false {
    _requestId = nanoid();

    if (listener != null) {
      _adropEventObserverChannel = MethodChannel(
        AdropChannel.adropEventListenerChannelOf(AdType.native, _requestId) ??
            '',
      );
      _adropEventObserverChannel?.setMethodCallHandler(_handleEvent);
    }
  }

  /// Returns `true` if an Adrop ad is loaded.
  bool get isLoaded => _loaded;

  /// Returns an Adrop ad's unitId.
  String get unitId => _unitId;

  /// Returns an Adrop ad's creativeId.
  String get creativeId => _creativeId;

  /// internal requestId for interaction.
  String get requestId => _requestId;

  /// Returns an Adrop native ad's properties.
  AdropNativeProperties get properties => _properties;

  /// Requests an ad from Adrop using the Ad unit ID of the Adrop ad.
  Future<void> load() async {
    return await _invokeChannel.invokeMethod(AdropMethod.loadAd, {
      "adType": AdType.native.index,
      "unitId": unitId,
      "requestId": _requestId
    });
  }

  Future<void> _handleEvent(MethodCall call) async {
    if (listener == null) return;

    var args = call.arguments;
    final event = AdropNativeEvent.from(args);

    if (args['creativeSizeWidth'] != null &&
        args['creativeSizeHeight'] != null) {
      _creativeSize = CreativeSize(
        width: args['creativeSizeWidth'],
        height: args['creativeSizeHeight'],
      );
    }

    switch (call.method) {
      case AdropMethod.didReceiveAd:
        _loaded = true;
        _creativeId = call.arguments['creativeId'] ?? '';
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
    }
  }
}
