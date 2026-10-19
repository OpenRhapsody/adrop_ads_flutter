import 'dart:convert';

import 'package:adrop_ads_flutter/src/native/adrop_native_asset.dart';
import 'package:flutter/foundation.dart';

class AdropNativeProfile {
  String? displayName;
  String? displayLogo;
  AdropNativeProfile({this.displayName, this.displayLogo});
}

class AdropNativeProperties {
  String? headline;
  String? body;
  String? creative;
  String? asset;
  String? destinationURL;
  String? callToAction;
  AdropNativeProfile? profile;
  late Map<String, String> extra;

  /// Media slots defined on the unit, keyed by slot ID (the first slot is `m1`). Empty for single-media creatives and backfill ads.
  late Map<String, AdropNativeAsset> extraAssets;
  bool isBackfilled;

  AdropNativeProperties.from(dynamic arguments)
      : headline = arguments != null ? arguments['headline'] ?? '' : '',
        body = arguments != null ? arguments['body'] ?? '' : '',
        creative = arguments != null ? arguments['creative'] ?? '' : '',
        asset = arguments != null ? arguments['asset'] ?? '' : '',
        destinationURL =
            arguments != null ? arguments['destinationURL'] ?? '' : '',
        callToAction = arguments != null ? arguments['callToAction'] ?? '' : '',
        profile = arguments != null
            ? AdropNativeProfile(
                displayLogo: arguments['displayLogo'],
                displayName: arguments['displayName'])
            : null,
        isBackfilled =
            arguments != null ? arguments['isBackfilled'] ?? false : false {
    extra = _extraToMap(arguments?['extra']);
    extraAssets = _extraAssetsToMap(arguments?['extraAssets']);
  }

  Map<String, String> _extraToMap(dynamic jsonString) {
    Map<String, String> extra = {};
    if (jsonString == null) return extra;

    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      parsed.forEach((key, value) {
        if (value is String) {
          extra[key] = value;
        }
      });
    } catch (e) {
      debugPrint('Error parsing extra: $e');
    }

    return extra;
  }

  /// Parses a JSON string shaped like `extra`, `{ "<id>": { id, asset, creative, cover?, type?, isVideo } }`.
  /// Order is not guaranteed (the iOS bridge serializes a Dictionary), so look slots up by ID.
  /// Returns an empty map when the value is missing or not valid JSON.
  Map<String, AdropNativeAsset> _extraAssetsToMap(dynamic jsonString) {
    Map<String, AdropNativeAsset> assets = {};
    if (jsonString == null) return assets;

    try {
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      parsed.forEach((key, value) {
        if (value is Map) {
          assets[key] = _assetFrom(key, value);
        }
      });
    } catch (e) {
      debugPrint('Error parsing extraAssets: $e');
    }

    return assets;
  }

  AdropNativeAsset _assetFrom(String key, Map value) {
    final id = value['id'];
    final asset = value['asset'];
    final creative = value['creative'];
    final cover = value['cover'];
    final type = value['type'];
    return AdropNativeAsset(
      id: id is String && id.isNotEmpty ? id : key,
      asset: asset is String ? asset : '',
      creative: creative is String ? creative : '',
      cover: cover is String && cover.isNotEmpty ? cover : null,
      type: type is String && type.isNotEmpty ? type : null,
      isVideo: value['isVideo'] == true,
    );
  }
}
