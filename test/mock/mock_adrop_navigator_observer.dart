import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MockAdropNavigatorObserver extends NavigatorObserver {
  static final MockAdropNavigatorObserver _instance =
      MockAdropNavigatorObserver._internal();

  factory MockAdropNavigatorObserver() => _instance;

  final MethodChannel _methodChannel =
      const MethodChannel(AdropChannel.invokeChannel);

  static String _current = "";
  static int _size = 0;

  static String last() {
    return _current;
  }

  MockAdropNavigatorObserver._internal();

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
    _methodChannel
        .invokeMethod(AdropMethod.pageTrack, {"page": _current, "size": _size});
  }

  void clear() {
    _size = 0;
    _current = '';
  }
}
