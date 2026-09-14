import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

/// The paid-event payload is built by two independently written native bridges, so the
/// failure mode is a key or spelling that differs on only one platform — the value then
/// silently arrives empty or with the wrong precision.
main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdropAdValue.fromMap', () {
    test('parses the payload both bridges send', () {
      final value = AdropAdValue.fromMap({
        'network': 'admob',
        'adSourceName': 'AppLovin',
        'valueMicros': 5000,
        'currencyCode': 'USD',
        'precision': 'precise',
      });

      expect(value.network, 'admob');
      expect(value.adSourceName, 'AppLovin');
      expect(value.valueMicros, 5000);
      expect(value.currencyCode, 'USD');
      expect(value.precision, AdropAdValuePrecision.precise);
      expect(value.value, closeTo(0.005, 1e-9));
    });

    test('maps every precision name', () {
      const expected = {
        'unknown': AdropAdValuePrecision.unknown,
        'estimated': AdropAdValuePrecision.estimated,
        'publisherProvided': AdropAdValuePrecision.publisherProvided,
        'precise': AdropAdValuePrecision.precise,
      };

      expected.forEach((name, precision) {
        final value = AdropAdValue.fromMap({
          'network': 'admob',
          'valueMicros': 1,
          'currencyCode': 'KRW',
          'precision': name,
        });
        expect(value.precision, precision, reason: name);
      });
    });

    test(
        'falls back to unknown rather than throwing on an unexpected precision',
        () {
      // Guards against a bridge regressing to `name.lowercase()`, which would send
      // `publisher_provided`, and against AdMob adding a case.
      for (final raw in ['publisher_provided', 'brand_new_case', null, 3]) {
        final value = AdropAdValue.fromMap({
          'network': 'admob',
          'valueMicros': 1,
          'currencyCode': 'KRW',
          'precision': raw,
        });
        expect(value.precision, AdropAdValuePrecision.unknown, reason: '$raw');
      }
    });

    test('tolerates a missing adSourceName and missing fields', () {
      final value = AdropAdValue.fromMap({'precision': 'estimated'});

      expect(value.adSourceName, isNull);
      expect(value.network, '');
      expect(value.currencyCode, '');
      expect(value.valueMicros, 0);
      expect(value.precision, AdropAdValuePrecision.estimated);
    });

    test(
        'keeps large micros exact — low-denomination currencies overflow 32 bits',
        () {
      // 2,147,483,647 micros is the Int ceiling a bridge would silently wrap at.
      final value = AdropAdValue.fromMap({
        'network': 'admob',
        'valueMicros': 9000000000,
        'currencyCode': 'KRW',
        'precision': 'estimated',
      });

      expect(value.valueMicros, 9000000000);
      expect(value.value, closeTo(9000.0, 1e-9));
    });
  });
}
