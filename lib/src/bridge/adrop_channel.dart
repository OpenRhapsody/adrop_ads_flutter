import 'package:adrop_ads_flutter/src/adrop_ad.dart';

class AdropChannel {
  static const invokeChannel = "io.adrop.adrop-ads";
  static const bannerEventListenerChannel = "$invokeChannel/banner";
  static const nativeEventListenerChannel = "$invokeChannel/native";

  static String bannerEventListenerChannelOf(int id) =>
      "${bannerEventListenerChannel}_$id";
  static String? adropEventListenerChannelOf(AdType adType, String id) {
    switch (adType) {
      case AdType.interstitial:
        return "$invokeChannel/interstitial_$id";
      case AdType.rewarded:
        return "$invokeChannel/rewarded_$id";
      case AdType.popup:
        return "$invokeChannel/popup_$id";
      case AdType.native:
        return "$invokeChannel/native_$id";
      case AdType.undefined:
        return null;
    }
  }
}
