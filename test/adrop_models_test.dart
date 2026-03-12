import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/model/call_create_ad.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('AdropErrorCode', () {
    test('getByCode returns correct error code', () {
      expect(AdropErrorCode.getByCode('ERROR_CODE_NETWORK'),
          AdropErrorCode.network);
      expect(AdropErrorCode.getByCode('ERROR_CODE_INTERNAL'),
          AdropErrorCode.internal);
      expect(AdropErrorCode.getByCode('ERROR_CODE_INITIALIZE'),
          AdropErrorCode.initialize);
      expect(AdropErrorCode.getByCode('ERROR_CODE_INVALID_UNIT'),
          AdropErrorCode.invalidUnit);
      expect(AdropErrorCode.getByCode('ERROR_CODE_AD_INACTIVE'),
          AdropErrorCode.inactive);
      expect(AdropErrorCode.getByCode('ERROR_CODE_AD_NO_FILL'),
          AdropErrorCode.adNoFill);
      expect(AdropErrorCode.getByCode('ERROR_CODE_AD_LOAD_DUPLICATED'),
          AdropErrorCode.adLoadDuplicate);
      expect(AdropErrorCode.getByCode('ERROR_CODE_AD_LOADING'),
          AdropErrorCode.adLoading);
      expect(AdropErrorCode.getByCode('ERROR_CODE_AD_EMPTY'),
          AdropErrorCode.adEmpty);
      expect(AdropErrorCode.getByCode('ERROR_CODE_AD_SHOWN'),
          AdropErrorCode.adShown);
    });

    test('getByCode with unknown code returns undefined', () {
      expect(AdropErrorCode.getByCode('UNKNOWN'), AdropErrorCode.undefined);
      expect(AdropErrorCode.getByCode(''), AdropErrorCode.undefined);
      expect(AdropErrorCode.getByCode('RANDOM_CODE'), AdropErrorCode.undefined);
    });
  });

  group('BrowserTarget', () {
    test('fromOrdinal(0) returns external', () {
      expect(BrowserTarget.fromOrdinal(0), BrowserTarget.external);
    });

    test('fromOrdinal(1) returns internal', () {
      expect(BrowserTarget.fromOrdinal(1), BrowserTarget.internal);
    });

    test('fromOrdinal(null) returns null', () {
      expect(BrowserTarget.fromOrdinal(null), isNull);
    });

    test('fromOrdinal(99) returns null', () {
      expect(BrowserTarget.fromOrdinal(99), isNull);
    });

    test('fromOrdinal(-1) returns null', () {
      expect(BrowserTarget.fromOrdinal(-1), isNull);
    });
  });

  group('CreativeSize', () {
    test('stores width and height', () {
      const size = CreativeSize(width: 320.0, height: 50.0);
      expect(size.width, 320.0);
      expect(size.height, 50.0);
    });
  });

  group('CallCreateAd', () {
    test('toJson roundtrip', () {
      final ad = CallCreateAd(unitId: 'unit1', requestId: 'req1');
      final json = ad.toJson();
      expect(json['unitId'], 'unit1');
      expect(json['requestId'], 'req1');

      final restored = CallCreateAd.fromJson(json);
      expect(restored.unitId, 'unit1');
      expect(restored.requestId, 'req1');
    });

    test('fromJson with nulls defaults to empty string', () {
      final ad = CallCreateAd.fromJson({});
      expect(ad.unitId, '');
      expect(ad.requestId, '');
    });
  });

  group('AdropTheme', () {
    test('light value', () {
      expect(AdropTheme.light.value, 'light');
    });

    test('dark value', () {
      expect(AdropTheme.dark.value, 'dark');
    });

    test('auto value', () {
      expect(AdropTheme.auto.value, 'auto');
    });
  });

  group('AdropProperties', () {
    test('enum codes', () {
      expect(AdropProperties.age.code, 'AGE');
      expect(AdropProperties.birth.code, 'BIRTH');
      expect(AdropProperties.gender.code, 'GDR');
    });
  });

  group('AdropGender', () {
    test('enum codes', () {
      expect(AdropGender.male.code, 'M');
      expect(AdropGender.female.code, 'F');
      expect(AdropGender.other.code, 'O');
      expect(AdropGender.unknown.code, 'U');
    });
  });
}
