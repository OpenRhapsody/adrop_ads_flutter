import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/adrop_ad.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_channel.dart';
import 'package:adrop_ads_flutter/src/bridge/adrop_method.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock/mock_adrop_interstitial_ad.dart';
import 'mock/mock_adrop_navigator_observer.dart';
import 'mock/mock_adrop_rewarded_ad.dart';
import 'mock/mock_route.dart';

main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var observer = MockAdropNavigatorObserver();
  const invokeChannel = MethodChannel(AdropChannel.invokeChannel);

  Map<String, int> pages = {};
  Map<String, String> attached = {};

  const bannerUnit = "banner_unit_id";
  const interstitialUnit = "banner_unit_id";
  const rewardedUnit = "rewarded_unit_id";

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(invokeChannel, (call) async {
    switch (call.method) {
      case AdropMethod.pageTrack:
        final page = call.arguments['page'];
        final routeSize = call.arguments['size'];
        pages[page] = routeSize;
        break;
      case AdropMethod.pageAttach:
        final unitId = call.arguments['unitId'];
        final page = call.arguments['page'];
        attached[unitId] = page;
        break;
      default:
    }

    return null;
  });

  setUp(() async {
    await Adrop.initialize(true);
  });

  tearDown(() async {
    pages.clear();
    observer.clear();
  });

  group("track pages test", () {
    test("push pages", () async {
      observer.didPush(MockRoute(name: "route_1"), null);
      observer.didPush(MockRoute(name: "route_2"), null);
      observer.didPush(MockRoute(name: "route_3"), null);
      observer.didPush(MockRoute(name: "route_4"), null);
      expect(pages["route_1"], 1);
      expect(pages["route_2"], 2);
      expect(pages["route_3"], 3);
      expect(pages["route_4"], 4);
      expect(MockAdropNavigatorObserver.last(), "route_4");
    });

    test("push, replace pages", () async {
      var old = MockRoute(name: "pushed");
      var newRoute = MockRoute(name: "replaced");
      observer.didPush(old, null);
      observer.didReplace(newRoute: newRoute, oldRoute: old);
      expect(pages[old.settings.name], 1);
      expect(pages[newRoute.settings.name], 2);
      expect(MockAdropNavigatorObserver.last(), newRoute.settings.name);
    });

    test("push pages, back home", () async {
      var home = MockRoute(name: "home");
      observer.didPush(home, null);
      observer.didPush(MockRoute(name: "new"), null);
      observer.didPop(MockRoute(name: "new"), home);
      expect(MockAdropNavigatorObserver.last(), home.settings.name);
    });

    test("push pages, back home", () async {
      var home = MockRoute(name: "home");
      observer.didPush(home, null);
      observer.didPush(MockRoute(name: "new"), null);
      observer.didPop(MockRoute(name: "new"), home);
      expect(MockAdropNavigatorObserver.last(), home.settings.name);
    });

    test("push pages, remove pages", () async {
      var home = MockRoute(name: "home");
      var newRoute = MockRoute(name: "new");
      observer.didPush(home, null);
      observer.didPush(newRoute, null);
      observer.didRemove(home, newRoute);
      expect(MockAdropNavigatorObserver.last(), home.settings.name);
    });
  });

  group("attach test", () {
    test("banner attach", () async {
      var home = MockRoute(name: "home");
      observer.didPush(home, null);
      invokeChannel.invokeMethod(AdropMethod.pageAttach,
          {"unitId": bannerUnit, "page": MockAdropNavigatorObserver.last()});
      expect(attached[bannerUnit], home.settings.name);
    });

    test("interstitial attach", () async {
      var interstitialPage = MockRoute(name: "interstitial_page");
      observer.didPush(interstitialPage, null);

      var interstitial = MockAdropInterstitialAd(
          unitId: interstitialUnit,
          listener: const AdropInterstitialListener());

      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.interstitial, interstitial.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel?.invokeMethod(AdropMethod.didImpression);

      expect(attached[interstitialUnit], interstitialPage.settings.name);
    });

    test("rewarded attach", () async {
      var rewardedPage = MockRoute(name: "rewarded_page");
      observer.didPush(rewardedPage, null);

      var rewarded = MockAdropRewardedAd(
          unitId: rewardedUnit, listener: AdropRewardedListener());

      final adropEventObserverChannelName =
          AdropChannel.adropEventListenerChannelOf(
              AdType.rewarded, rewarded.requestId);
      final adropEventObserverChannel = adropEventObserverChannelName != null
          ? MethodChannel(adropEventObserverChannelName)
          : null;
      await adropEventObserverChannel?.invokeMethod(AdropMethod.didImpression);

      expect(attached[rewardedUnit], rewardedPage.settings.name);
    });

    tearDown(() async {
      attached.clear();
    });
  });
}
