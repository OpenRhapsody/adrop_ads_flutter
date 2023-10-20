import 'package:adrop_ads_flutter/adrop_platform_interface.dart';

export 'package:adrop_ads_flutter/banner/adrop_banner.dart';
export 'package:adrop_ads_flutter/banner/adrop_banner_container.dart';

class Adrop {
  static Future<void> initialize(bool production) async {
    return await AdropPlatform.instance.initialize(production);
  }
}
