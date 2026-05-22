import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdropAdChoicesPosition', () {
    test('enum integer contract is stable for MethodChannel', () {
      // The native side reconstructs the enum from these integers
      // (iOS rawValue, Android fromValue); changing them breaks compatibility,
      // so they are intentionally pinned.
      expect(AdropAdChoicesPosition.topLeft.value, 0);
      expect(AdropAdChoicesPosition.topRight.value, 1);
      expect(AdropAdChoicesPosition.bottomLeft.value, 2);
      expect(AdropAdChoicesPosition.bottomRight.value, 3);
    });

    test('default for AdropNativeAd is topRight', () {
      final ad = AdropNativeAd(unitId: 'test-unit');
      expect(ad.preferredAdChoicesPosition, AdropAdChoicesPosition.topRight);
    });

    test('AdropNativeAd accepts a custom position', () {
      final ad = AdropNativeAd(
        unitId: 'test-unit',
        preferredAdChoicesPosition: AdropAdChoicesPosition.bottomLeft,
      );
      expect(ad.preferredAdChoicesPosition, AdropAdChoicesPosition.bottomLeft);
    });
  });
}
