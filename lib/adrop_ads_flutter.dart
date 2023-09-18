
import 'adrop_ads_flutter_platform_interface.dart';

class AdropAdsFlutter {
  Future<String?> getPlatformVersion() {
    return AdropAdsFlutterPlatform.instance.getPlatformVersion();
  }
}
