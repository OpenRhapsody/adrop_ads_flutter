import 'package:adrop_ads_flutter/src/adrop_error_code.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_event.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('AdropNativeEvent', () {
    test('from(args) parses unitId, method, errorCode', () {
      final event = AdropNativeEvent.from({
        'unitId': 'test_unit',
        'method': 'onAdReceived',
        'errorCode': 'ERROR_CODE_NETWORK',
      });

      expect(event.unitId, 'test_unit');
      expect(event.method, 'onAdReceived');
      expect(event.errorCode, AdropErrorCode.network);
    });

    test('from(args) parses properties', () {
      final event = AdropNativeEvent.from({
        'unitId': 'test_unit',
        'method': 'onAdReceived',
        'headline': 'Test Headline',
        'body': 'Test Body',
        'creative': 'https://example.com/image.png',
        'callToAction': 'Click Here',
      });

      expect(event.properties.headline, 'Test Headline');
      expect(event.properties.body, 'Test Body');
      expect(event.properties.creative, 'https://example.com/image.png');
      expect(event.properties.callToAction, 'Click Here');
    });

    test('from(null) returns safe defaults', () {
      final event = AdropNativeEvent.from(null);

      expect(event.unitId, '');
      expect(event.method, '');
      expect(event.errorCode, isNull);
      expect(event.properties.headline, '');
      expect(event.properties.body, '');
    });
  });
}
