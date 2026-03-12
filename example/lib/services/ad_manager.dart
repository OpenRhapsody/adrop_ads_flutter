import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import '../constants/adrop_unit_id.dart';

class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  AdropPopupAd? _startupPopup;
  AdropInterstitialAd? _exitInterstitial;

  // ── Startup Popup ──
  void preloadStartupPopup() {
    _startupPopup = AdropPopupAd(
      unitId: AdropUnitId.popupCenter,
      listener: AdropPopupListener(
        onAdReceived: (ad) => debugPrint('[AdManager] startup popup ready'),
        onAdFailedToReceive: (ad, err) =>
            debugPrint('[AdManager] startup popup failed: $err'),
      ),
    );
    _startupPopup!.load();
  }

  void showStartupPopup() {
    if (_startupPopup?.isLoaded == true) {
      _startupPopup!.show();
    }
  }

  // ── Exit Interstitial ──
  void preloadExitInterstitial() {
    _exitInterstitial = AdropInterstitialAd(
      unitId: AdropUnitId.interstitial,
      listener: AdropInterstitialListener(
        onAdReceived: (ad) => debugPrint('[AdManager] exit interstitial ready'),
        onAdFailedToReceive: (ad, err) =>
            debugPrint('[AdManager] exit interstitial failed: $err'),
        onAdDidDismissFullScreen: (ad) {
          SystemNavigator.pop();
        },
        onAdFailedToShowFullScreen: (ad, err) {
          SystemNavigator.pop();
        },
      ),
    );
    _exitInterstitial!.load();
  }

  Future<bool> showExitInterstitial() async {
    if (_exitInterstitial?.isLoaded == true) {
      _exitInterstitial!.show();
      return true;
    }
    return false;
  }

  // ── Cleanup ──
  void destroyAll() {
    _startupPopup?.dispose();
    _startupPopup = null;
    _exitInterstitial?.dispose();
    _exitInterstitial = null;
  }
}
