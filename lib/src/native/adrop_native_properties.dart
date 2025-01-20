import 'dart:convert';

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
  AdropNativeProfile? profile;
  late Map<String, String> extra;

  AdropNativeProperties.from(dynamic arguments)
      : headline = arguments != null ? arguments['headline'] ?? '' : '',
        body = arguments != null ? arguments['body'] ?? '' : '',
        creative = arguments != null ? arguments['creative'] ?? '' : '',
        asset = arguments != null ? arguments['asset'] ?? '' : '',
        destinationURL =
            arguments != null ? arguments['destinationURL'] ?? '' : '',
        profile = arguments != null
            ? AdropNativeProfile(
                displayLogo: arguments['displayLogo'],
                displayName: arguments['displayName'])
            : null {
    extra = _extraToMap(arguments?['extra']);
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
}
