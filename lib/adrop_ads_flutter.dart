import 'adrop_ads_flutter_platform_interface.dart';

class AdropAdsFlutter {
  static Future<void> initialize(bool production) async {
    return await AdropAdsFlutterPlatform.instance.initialize(production);
  }
}
