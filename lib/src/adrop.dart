import 'adrop_platform_interface.dart';

class Adrop {
  /// Initializes Adrop
  ///
  /// [production] When false, display error log in sdk
  /// [targetCountries] If you are using this SDK in specific countries, pass an array of ISO 3166 alpha-2 country codes.
  /// [useInAppBrowser] (Only iOS) If you want to use the in-app browser, set it to true.
  static Future<void> initialize(bool production,
      {List<String>? targetCountries, bool? useInAppBrowser}) async {
    return await AdropPlatform.instance.initialize(
        production, targetCountries ?? [], useInAppBrowser ?? false);
  }
}
