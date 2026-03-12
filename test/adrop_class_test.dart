import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  Map<String, dynamic> lastCall = {};
  bool shouldThrowError = false;

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    if (shouldThrowError) {
      throw PlatformException(code: 'ERROR', message: 'Test error');
    }
    switch (call.method) {
      case AdropMethod.initialize:
        lastCall = {
          'method': call.method,
          'production': call.arguments['production'],
          'targetCountries': call.arguments['targetCountries'],
          'useInAppBrowser': call.arguments['useInAppBrowser'],
        };
        return null;

      case AdropMethod.setUID:
        lastCall = {
          'method': call.method,
          'uid': call.arguments['uid'],
        };
        return null;

      case AdropMethod.setTheme:
        lastCall = {
          'method': call.method,
          'theme': call.arguments['theme'],
        };
        return null;

      default:
        return null;
    }
  });

  setUp(() {
    lastCall.clear();
    shouldThrowError = false;
  });

  group('Adrop', () {
    test('initialize calls platform with correct args', () async {
      await Adrop.initialize(true);
      expect(lastCall['method'], AdropMethod.initialize);
      expect(lastCall['production'], true);
      expect(lastCall['targetCountries'], []);
      expect(lastCall['useInAppBrowser'], false);
    });

    test('setUID calls platform', () async {
      await Adrop.setUID('user123');
      expect(lastCall['method'], AdropMethod.setUID);
      expect(lastCall['uid'], 'user123');
    });

    test('setTheme light passes correct value', () async {
      await Adrop.setTheme(AdropTheme.light);
      expect(lastCall['method'], AdropMethod.setTheme);
      expect(lastCall['theme'], 'light');
    });

    test('setTheme dark passes correct value', () async {
      await Adrop.setTheme(AdropTheme.dark);
      expect(lastCall['theme'], 'dark');
    });

    test('setTheme auto passes correct value', () async {
      await Adrop.setTheme(AdropTheme.auto);
      expect(lastCall['theme'], 'auto');
    });

    test('setUID catches errors gracefully', () async {
      shouldThrowError = true;
      // Should not throw — errors are caught internally
      await Adrop.setUID('user123');
      expect(lastCall, isEmpty);
    });

    test('setTheme catches errors gracefully', () async {
      shouldThrowError = true;
      // Should not throw — errors are caught internally
      await Adrop.setTheme(AdropTheme.light);
      expect(lastCall, isEmpty);
    });

    test('consentManager is singleton', () {
      final cm1 = Adrop.consentManager;
      final cm2 = Adrop.consentManager;
      expect(identical(cm1, cm2), true);
    });
  });
}
