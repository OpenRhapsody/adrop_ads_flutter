import 'adrop_platform_interface.dart';

class Adrop {
  /// Initializes Adrop
  ///
  /// [production] When false, display error log in sdk
  static Future<void> initialize(bool production) async {
    return await AdropPlatform.instance.initialize(production);
  }
}
