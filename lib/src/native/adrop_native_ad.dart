import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/adrop_error_code.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:adrop_ads_flutter/src/model/browser_target.dart';
import 'package:adrop_ads_flutter/src/model/creative_size.dart';
import 'package:adrop_ads_flutter/src/native/adrop_ad_choices_position.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_event.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_listener.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_properties.dart';
import 'package:adrop_ads_flutter/src/utils/id.dart';
import 'package:adrop_ads_flutter/src/utils/loads_batch.dart';
import 'package:flutter/services.dart';

/// AdropNativeAd class responsible for requesting native ads.
///
/// [unitId] required Ad unit ID
/// [listener] optional invoked when a response from load method called back.
/// [useCustomClick] optional, if true, the ad will use custom click handling.
/// [preferredAdChoicesPosition] optional preferred display position of the
/// AdChoices icon on AdMob backfill native ads. Has no effect on direct ads,
/// and backfill networks such as AdMob may ignore it per their policy. Defaults
/// to [AdropAdChoicesPosition.topRight].
class AdropNativeAd {
  static const MethodChannel _invokeChannel =
      MethodChannel(AdropChannel.invokeChannel);

  final String _unitId;
  final bool useCustomClick;
  final AdropAdChoicesPosition preferredAdChoicesPosition;
  final AdropNativeListener? listener;
  late final String _requestId;
  late final MethodChannel? _adropEventObserverChannel;
  bool _disposed = false;
  CreativeSize get creativeSize => _creativeSize;

  String _creativeId = '';
  String _txId = '';
  String _campaignId = '';
  String _destinationURL = '';
  int? _browserTarget;
  String _creativeType = 'display';
  bool _loaded;
  AdropNativeProperties _properties = AdropNativeProperties.from(null);
  CreativeSize _creativeSize = const CreativeSize(width: 0.0, height: 0.0);

  AdropNativeAd({
    required String unitId,
    this.useCustomClick = false,
    this.preferredAdChoicesPosition = AdropAdChoicesPosition.topRight,
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
    } else {
      _adropEventObserverChannel = null;
    }
  }

  /// Wraps an ad already loaded natively by [loads]. Unlike the default
  /// constructor (hydrated later by the `didReceiveAd` event, which never
  /// fires on the batch path), all metadata is seeded from the batch response
  /// so [properties], [creativeSize], [isLoaded] etc. are valid immediately.
  AdropNativeAd._preloaded({
    required String unitId,
    required String requestId,
    required Map metadata,
    this.useCustomClick = false,
    this.listener,
  })  : _unitId = unitId,
        preferredAdChoicesPosition = AdropAdChoicesPosition.topRight,
        _loaded = true {
    _requestId = requestId;
    _creativeId = metadata['creativeId'] ?? '';
    _txId = metadata['txId'] ?? '';
    _campaignId = metadata['campaignId'] ?? '';
    _destinationURL = metadata['destinationURL'] ?? '';
    _browserTarget = metadata['browserTarget'];
    _creativeType = metadata['creativeType'] ?? 'display';
    _properties = AdropNativeProperties.from(metadata);
    final width = metadata['creativeSizeWidth'];
    final height = metadata['creativeSizeHeight'];
    if (width != null && height != null) {
      _creativeSize = CreativeSize(width: width, height: height);
    }

    if (listener != null) {
      _adropEventObserverChannel = MethodChannel(
        AdropChannel.adropEventListenerChannelOf(AdType.native, requestId) ??
            '',
      );
      _adropEventObserverChannel?.setMethodCallHandler(_handleEvent);
    } else {
      _adropEventObserverChannel = null;
    }
  }

  /// Loads up to 5 native ads with a single network request. The returned
  /// instances are already loaded ([isLoaded] is `true`) — do NOT call [load]
  /// on them (a second load would issue another network request). Bind each
  /// to an [AdropNativeAdView] as usual; re-mounting a recycled list item
  /// re-binds the same instance.
  ///
  /// Batch-loaded ads are always direct ads ([isBackfilled] is `false`) —
  /// the batch path intentionally skips the backfill fallback.
  ///
  /// Every returned instance owns a native WebView (~5-15 MB): call [dispose]
  /// on each one when done, including instances never bound to a view.
  ///
  /// Throws a [PlatformException] whose `code` is an [AdropErrorCode] name
  /// (e.g. `ERROR_CODE_AD_NO_FILL` when nothing filled).
  static Future<List<AdropNativeAd>> loads({
    required String unitId,
    bool useCustomClick = false,
    AdropNativeListener? listener,
  }) async {
    final requestIds = List.generate(maxLoadsBatch, (_) => nanoid());
    final response =
        await _invokeChannel.invokeMethod(AdropMethod.loadsNative, {
      'unitId': unitId,
      'requestIds': requestIds,
      'useCustomClick': useCustomClick,
    });
    final map = response is Map ? response : const {};
    final filledIds = (map['requestIds'] as List?)?.cast<String>() ?? const [];
    final metas = map['ads'] as List? ?? const [];

    final ads = <AdropNativeAd>[];
    for (var i = 0; i < filledIds.length && i < metas.length; i++) {
      ads.add(AdropNativeAd._preloaded(
        unitId: unitId,
        requestId: filledIds[i],
        metadata: metas[i] as Map,
        useCustomClick: useCustomClick,
        listener: listener,
      ));
    }
    return ads;
  }

  /// Returns `true` if an Adrop ad is loaded.
  bool get isLoaded => _loaded;

  /// Returns an Adrop ad's unitId.
  String get unitId => _unitId;

  /// Returns an Adrop ad's creative id.
  String get creativeId => _creativeId;

  /// internal requestId for interaction.
  String get requestId => _requestId;

  /// Returns an Adrop ad's transaction id.
  String get txId => _txId;

  /// Returns an Adrop ad's campaign id.
  String get campaignId => _campaignId;

  /// Returns an Adrop ad's destination url.
  String get destinationURL => _destinationURL;

  /// Returns an Adrop ad's browser target.
  BrowserTarget? get browserTarget {
    return BrowserTarget.fromOrdinal(_browserTarget);
  }

  /// Returns an Adrop native ad's properties.
  AdropNativeProperties get properties => _properties;

  /// Returns `true` if the ad is a backfill ad.
  bool get isBackfilled => _properties.isBackfilled;

  /// Creative medium of the loaded ad: `'display'` or `'video'`.
  /// Defaults to `'display'` before an ad is received.
  String get creativeType => _creativeType;

  /// Requests an ad from Adrop using the Ad unit ID of the Adrop ad.
  Future<void> load() async {
    assert(!_disposed,
        'AdropNativeAd.load() called after dispose(). A disposed ad cannot be reused; create a new AdropNativeAd instance.');
    if (_disposed) return;
    return await _invokeChannel.invokeMethod(AdropMethod.loadAd, {
      "adType": AdType.native.index,
      "unitId": unitId,
      "useCustomClick": useCustomClick,
      "preferredAdChoicesPosition": preferredAdChoicesPosition.value,
      "requestId": _requestId,
    });
  }

  /// Disposes the native ad to free native resources (the underlying WebView
  /// and, for backfill ads, the AdMob native ad).
  ///
  /// Call this once the ad is no longer displayed — for example when the widget
  /// hosting [AdropNativeAdView] is removed from the tree. The instance cannot
  /// be reused after dispose; create a new [AdropNativeAd] to request another
  /// ad. Failing to dispose leaks the native WebView (~5–15 MB per instance),
  /// which can lead to OOM crashes in feed-style screens.
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _adropEventObserverChannel?.setMethodCallHandler(null);
    return await _invokeChannel.invokeMethod(AdropMethod.disposeAd, {
      "adType": AdType.native.index,
      "requestId": _requestId,
    });
  }

  Future<void> _handleEvent(MethodCall call) async {
    if (_disposed || listener == null) return;

    var args = call.arguments;
    final event = AdropNativeEvent.from(args);

    _creativeId = call.arguments['creativeId'] ?? '';
    _txId = call.arguments['txId'] ?? '';
    _campaignId = call.arguments['campaignId'] ?? '';
    _destinationURL = call.arguments['destinationURL'] ?? '';
    _browserTarget = call.arguments['browserTarget'];
    _creativeType = call.arguments['creativeType'] ?? 'display';

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
      case AdropMethod.didVideoStart:
        listener?.onAdVideoStart?.call(this);
        break;
      case AdropMethod.didVideoEnd:
        listener?.onAdVideoEnd?.call(this);
        break;
    }
  }
}
