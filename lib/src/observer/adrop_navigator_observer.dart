import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../bridge/adrop_channel.dart';
import '../bridge/adrop_method.dart';

/// An interface for observing the behavior of a [Navigator] to measure the frequency of ad impressions.
class AdropNavigatorObserver extends NavigatorObserver {
  static final AdropNavigatorObserver _instance = AdropNavigatorObserver._internal();

  factory AdropNavigatorObserver() => _instance;

  final MethodChannel _methodChannel = const MethodChannel(AdropChannel.invokeChannel);

  static String _current = "";
  static int _size = 0;
  static Timer? _timer;

  /// The current route name
  static String last() {
    return _current;
  }

  AdropNavigatorObserver._internal();

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _setCurrentPage(route, true);
    _invoke();
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _setCurrentPage(newRoute, true);
    _invoke();
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _setCurrentPage(previousRoute, false);
    _invoke();
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);
    _setCurrentPage(route, false);
    _invoke();
  }

  void _setCurrentPage(Route? route, bool push) {
    if (route == null) return;

    if (push) {
      _size++;
    } else {
      _size--;
    }

    _current = route.settings.name ?? "";
  }

  void _invoke() {
    if (_timer != null) {
      _timer?.cancel();
    }

    _timer = Timer(const Duration(microseconds: 50), () {
      try {
        _methodChannel.invokeMethod(AdropMethod.pageTrack, {"page": _current, "size": _size});
      } catch (_) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }
}
