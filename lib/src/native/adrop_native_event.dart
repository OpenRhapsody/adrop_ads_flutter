import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/native/adrop_native_properties.dart';

class AdropNativeEvent extends AdropEvent {
  AdropNativeProperties properties;

  AdropNativeEvent.from(dynamic arguments)
      : properties = AdropNativeProperties.from(arguments),
        super.from(arguments);
}
