import 'package:flutter/cupertino.dart';

/// An interface for observing the behavior of a [Navigator] to measure the frequency of ad impressions.
@Deprecated("This class is deprecated and will be removed in the next version.")
class AdropNavigatorObserver extends NavigatorObserver {
  static final AdropNavigatorObserver _instance =
      AdropNavigatorObserver._internal();

  factory AdropNavigatorObserver() => _instance;

  static const String _current = "";

  /// The current route name
  static String last() {
    return _current;
  }

  AdropNavigatorObserver._internal();
}
