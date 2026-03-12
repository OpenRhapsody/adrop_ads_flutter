import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);
  Map<String, dynamic> storedProperties = {};
  Map<String, dynamic> lastLogEvent = {};

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    switch (call.method) {
      case AdropMethod.setProperty:
        final key = call.arguments['key'] as String;
        final value = call.arguments['value'];
        if (value == null) {
          storedProperties.remove(key);
        } else {
          storedProperties[key] = value;
        }
        return null;

      case AdropMethod.sendEvent:
        lastLogEvent = {
          'name': call.arguments['name'],
          'params': call.arguments['params'],
        };
        return null;

      case AdropMethod.getProperty:
        return storedProperties;

      default:
        return null;
    }
  });

  setUp(() {
    storedProperties.clear();
    lastLogEvent.clear();
  });

  group('AdropMetrics', () {
    test('setProperty sends key/value to native', () async {
      await AdropMetrics.setProperty('age', '25');
      expect(storedProperties['age'], '25');
    });

    test('setProperty with null value removes property', () async {
      storedProperties['age'] = '25';
      await AdropMetrics.setProperty('age', null);
      expect(storedProperties.containsKey('age'), false);
    });

    test('sendEvent sends name and params', () async {
      await AdropMetrics.sendEvent('purchase', {'amount': 100});
      expect(lastLogEvent['name'], 'purchase');
      expect(lastLogEvent['params'], {'amount': 100});
    });

    test('sendEvent without params', () async {
      await AdropMetrics.sendEvent('app_open');
      expect(lastLogEvent['name'], 'app_open');
      expect(lastLogEvent['params'], isNull);
    });

    test('properties() returns Map from native', () async {
      storedProperties['key1'] = 'value1';
      storedProperties['key2'] = 'value2';
      final result = await AdropMetrics.properties();
      expect(result, {'key1': 'value1', 'key2': 'value2'});
    });

    test('properties() returns empty map on empty response', () async {
      final result = await AdropMetrics.properties();
      expect(result, isEmpty);
    });
  });
}
