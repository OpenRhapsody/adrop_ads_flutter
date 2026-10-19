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
      expect(props.extraAssets, isEmpty);
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

    test(
        'extraAssets JSON parsing returns Map<String, AdropNativeAsset> keyed by slot id',
        () {
      final props = AdropNativeProperties.from({
        'extraAssets': '{'
            '"m1":{"id":"m1","asset":"https://example.com/m1.png",'
            '"creative":"<html>m1</html>","type":"display","isVideo":false},'
            '"m2":{"id":"m2","asset":"https://example.com/m2.mp4",'
            '"creative":"<html>m2</html>","cover":"https://example.com/m2.jpg",'
            '"type":"video","isVideo":true}'
            '}',
      });

      expect(props.extraAssets.keys.toSet(), {'m1', 'm2'});

      final m1 = props.extraAssets['m1']!;
      expect(m1.id, 'm1');
      expect(m1.asset, 'https://example.com/m1.png');
      expect(m1.creative, '<html>m1</html>');
      expect(m1.cover, isNull);
      expect(m1.type, 'display');
      expect(m1.isVideo, isFalse);

      final m2 = props.extraAssets['m2']!;
      expect(m2.id, 'm2');
      expect(m2.asset, 'https://example.com/m2.mp4');
      expect(m2.creative, '<html>m2</html>');
      expect(m2.cover, 'https://example.com/m2.jpg');
      expect(m2.type, 'video');
      expect(m2.isVideo, isTrue);
    });

    test('extraAssets without type (legacy bridge) keeps type null', () {
      final props = AdropNativeProperties.from({
        'extraAssets': '{'
            '"m1":{"id":"m1","asset":"https://example.com/m1.mp4",'
            '"creative":"<html>m1</html>","isVideo":true},'
            '"m2":{"id":"m2","asset":"https://example.com/m2.png",'
            '"creative":"<html>m2</html>","type":"","isVideo":false}'
            '}',
      });

      final m1 = props.extraAssets['m1']!;
      expect(m1.type, isNull);
      expect(m1.isVideo, isTrue);

      // blank type is treated as absent
      final m2 = props.extraAssets['m2']!;
      expect(m2.type, isNull);
      expect(m2.isVideo, isFalse);
    });

    test('extraAssets without argument returns empty map', () {
      expect(AdropNativeProperties.from({}).extraAssets, isEmpty);
      expect(AdropNativeProperties.from({'extra': '{}'}).extraAssets, isEmpty);
    });

    test('extraAssets with invalid JSON returns empty map', () {
      final props = AdropNativeProperties.from({
        'extraAssets': 'not-valid-json',
      });

      expect(props.extraAssets, isEmpty);
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
