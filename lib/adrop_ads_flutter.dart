import 'adrop_ads_flutter_platform_interface.dart';

export 'package:adrop_ads_flutter/banner/adrop_banner.dart';
export 'package:adrop_ads_flutter/banner/adrop_banner_container.dart';
export 'package:adrop_ads_flutter/banner/adrop_banner_size.dart';


class AdropAdsFlutter {
  static Future<void> initialize(bool production) async {
    return await AdropAdsFlutterPlatform.instance.initialize(production);
  }
}
