class AdropMethod {
  static const initialize = "initialize";
  static const setUID = "setUid";
  static const setTheme = "setTheme";
  static const loadBanner = "loadBanner";
  static const disposeBanner = "disposeBanner";

  static const loadAd = "loadAd";
  static const showAd = "showAd";
  static const closeAd = "closeAd";
  static const customizeAd = "customizeAd";
  static const disposeAd = "disposeAd";

  static const setProperty = "setProperty";
  static const getProperty = "getProperty";
  static const logEvent = "logEvent";
  static const pageTrack = "pageTrack";
  static const pageAttach = "pageAttach";

  static const performClick = "performClick";

  // Consent methods
  static const requestConsentInfoUpdate = "requestConsentInfoUpdate";
  static const getConsentStatus = "getConsentStatus";
  static const canRequestAds = "canRequestAds";
  static const resetConsent = "resetConsent";
  static const setConsentDebugSettings = "setConsentDebugSettings";

  static const didReceiveAd = "onAdReceived";
  static const didClickAd = "onAdClicked";
  static const didFailToReceiveAd = "onAdFailedToReceive";

  static const didDismissFullScreen = "onAdDidDismissFullScreen";
  static const didPresentFullScreen = "onAdDidPresentFullScreen";
  static const didFailedToShowFullScreen = "onAdFailedToShowFullScreen";
  static const didImpression = "onAdImpression";
  static const willDismissFullScreen = "onAdWillDismissFullScreen";
  static const willPresentFullScreen = "onAdWillPresentFullScreen";
  static const didHandleEarnReward = "handleEarnReward";
}
