import 'package:adrop_ads_flutter/src/utils/id.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  group('nanoid', () {
    test('returns 21-char string', () {
      final id = nanoid();
      expect(id.length, 21);
    });

    test('uses valid alphabet chars', () {
      const alphabet =
          'ModuleSymbhasOwnPr0123456789ABCDEFGHNRVfgctiUvzKqYTJkLxpZXIjQW';
      final id = nanoid();
      for (final char in id.split('')) {
        expect(alphabet.contains(char), true,
            reason: 'Character "$char" is not in the nanoid alphabet');
      }
    });

    test('returns unique values', () {
      final ids = List.generate(100, (_) => nanoid());
      final uniqueIds = ids.toSet();
      expect(uniqueIds.length, ids.length);
    });
  });
}
