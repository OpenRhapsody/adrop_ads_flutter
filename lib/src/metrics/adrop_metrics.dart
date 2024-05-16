import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';

class AdropMetrics {
  static const _channel = MethodChannel(AdropChannel.invokeChannel);

  /// Sets a user property to a given value.
  ///
  /// [key] is the name of the user property to set.
  /// Setting a null [value] removes the user property.
  static Future<void> setProperty(String key, String value) async {
    return await _channel.invokeMethod(AdropMethod.setProperty, {"key": key, "value": value});
  }

  /// Logs a custom event with the given [name] and event [params].
  ///
  /// The event with the same [name] can have up to 20 [params].
  ///
  /// The [name] of the event. Some event names are reserved.
  /// See [setProperty] for the list of reserved event names.
  ///
  /// The map of event [params]. String, Integer, Float, Boolean param types are supported.
  static Future<void> logEvent(String name, [dynamic params]) async {
    return await _channel.invokeMethod(AdropMethod.logEvent, {"name": name, "params": params});
  }
}
