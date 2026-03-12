import 'package:adrop_ads_flutter/src/native/adrop_native_properties.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('AdropNativeProperties', () {
    test('from(null) returns empty defaults', () {
      final props = AdropNativeProperties.from(null);
      expect(props.headline, '');
      expect(props.body, '');
      expect(props.creative, '');
      expect(props.asset, '');
      expect(props.destinationURL, '');
      expect(props.callToAction, '');
      expect(props.profile, isNull);
      expect(props.extra, isEmpty);
      expect(props.isBackfilled, false);
    });

    test('from(valid map) populates all fields', () {
      final props = AdropNativeProperties.from({
        'headline': 'Test Headline',
        'body': 'Test Body',
        'creative': 'https://example.com/creative.png',
        'asset': 'https://example.com/asset.png',
        'destinationURL': 'https://example.com',
        'callToAction': 'Learn More',
        'displayName': 'Test Brand',
        'displayLogo': 'https://example.com/logo.png',
        'isBackfilled': true,
        'extra': '{"key1":"value1","key2":"value2"}',
      });

      expect(props.headline, 'Test Headline');
      expect(props.body, 'Test Body');
      expect(props.creative, 'https://example.com/creative.png');
      expect(props.asset, 'https://example.com/asset.png');
      expect(props.destinationURL, 'https://example.com');
      expect(props.callToAction, 'Learn More');
      expect(props.isBackfilled, true);
    });

    test('from(partial map) missing fields default to empty string', () {
      final props = AdropNativeProperties.from({
        'headline': 'Only Headline',
      });

      expect(props.headline, 'Only Headline');
      expect(props.body, '');
      expect(props.creative, '');
      expect(props.callToAction, '');
    });

    test('extra JSON parsing returns Map<String, String>', () {
      final props = AdropNativeProperties.from({
        'extra': '{"key1":"value1","key2":"value2"}',
      });

      expect(props.extra, {'key1': 'value1', 'key2': 'value2'});
    });

    test('extra with invalid JSON returns empty map', () {
      final props = AdropNativeProperties.from({
        'extra': 'not-valid-json',
      });

      expect(props.extra, isEmpty);
    });

    test('profile populated with displayName and displayLogo', () {
      final props = AdropNativeProperties.from({
        'displayName': 'Brand Name',
        'displayLogo': 'https://logo.png',
      });

      expect(props.profile, isNotNull);
      expect(props.profile?.displayName, 'Brand Name');
      expect(props.profile?.displayLogo, 'https://logo.png');
    });

    test('isBackfilled defaults to false', () {
      final props = AdropNativeProperties.from({});
      expect(props.isBackfilled, false);
    });
  });
}
