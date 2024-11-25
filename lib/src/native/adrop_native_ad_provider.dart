import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

class AdropNativeAdProvider extends InheritedWidget {
  final AdropNativeAd? ad;

  const AdropNativeAdProvider(
      {Key? key, required this.ad, required Widget child})
      : super(key: key, child: child);

  static AdropNativeAdProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdropNativeAdProvider>();
  }

  @override
  bool updateShouldNotify(covariant AdropNativeAdProvider oldWidget) {
    return ad != oldWidget.ad;
  }
}
