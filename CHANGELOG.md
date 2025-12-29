## 1.7.2
- Added User Messaging Platform (UMP) support for GDPR consent management on Android and iOS

## 1.7.1
- Support video ad
- Update dependencies
- Add gesture recognizers to UIKitView
- Fix Android and iOS useCustomClick functionality
- Added error code for backfill ad load failures

## 1.7.0
- Added backfill ad support: Automatically serves network ads when Adrop direct ads fail to load
- Added `Adrop.setTheme()` method to control ad display theme (light, dark, auto)
- Support for performance template in `AdropPopupAd`

## 1.2.0
- Added `close()` method to `AdropPopupAd` for programmatic ad dismissal
- Enhanced ad metadata with `txId` and `campaignId` for all ad types (`AdropBannerView`, `AdropInterstitialAd`, `AdropNativeAd`, `AdropPopupAd`, `AdropRewardedAd`)
- **Breaking Change**: Updated `AdropAdEventCallback` signature to provide comprehensive metadata instead of just `creativeId`
  - Before: `void Function(String unitId, String? creativeId)`
  - After: `void Function(String unitId, Map<String, dynamic>? metadata)`
  - Metadata includes: `creativeId`, `txId`, `campaignId`, `requestId`, `destinationURL`, `creativeSizeWidth`, `creativeSizeHeight`

## 1.1.8
- Improved gesture handling for `AdropBannerView` to prevent touch event conflicts with scrollable parent views
- Fixed iOS banner scroll interference issue by implementing proper gesture recognizers

## 1.1.7
- Enhanced layout rendering stability for `AdropBannerView`
- Enabled support for `useCustomClick` in `AdropNativeAd` to handle manual click events

## 1.1.6
- Fix the issue where the `onAdClicked` of the `AdropNativeAd` is not being called. 

## 1.1.5
- Android: Improved stability of `AdropNativeAdView`

## 1.1.4
- Added `AdropBannerView`, `AdropNativeAd` to support creative size

## 1.1.3
- Updated `AdropBannerView` mapping key to ensure unique native view identification and prevent conflicts in multiple view instances.

## 1.1.2
- Close `AdropPopupAd` when the ad called `dispose`

## 1.1.1
- Support preview ads using adId

## 1.1.0
- Support for multiple templates in `AdropPopupAd`
- [iOS] Resolved overlapping issue between Flutter platform view and `AdropPopupAd`

## 1.0.4
- Support `creative` in `AdropNativeProperties` for displaying CTA 

## 1.0.3
- Updated **dependency configuration**:
  `implementation 'io.adrop:adrop-ads'` -> `api 'io.adrop:adrop-ads'`

## 1.0.2
- use `Color.value` in `AdropPopupAd`

## 1.0.1
- Support `Adrop.setUID` for consistent web and app targeting
- Add the `destinationURL` property to the `AdropNativeProperties` class. 

## 1.0.0
- Support Adrop 1.0.0
- `AdropMetrics.properties()` for getting user properties 

## 0.7.0
- Support `AdropNativeAd`
- [iOS] Support enable to use in-app browser

## 0.6.1
- [iOS] Support `useInAppBrowser`

## 0.6.0
- Support property types - `String`, `int`, `double`, `bool`
- Callback for creative id
- Deprecated `AdropNavigatorObserver`

## 0.5.2
- Add error code: Account usage limit exceeded 

## 0.5.1
- Update sdk

## 0.5.0
- Add `AdropPopupAd`
- Support Splash Ad
- Target countries

## 0.4.2
- Add `AdropNavigatorObserver` to measure the frequency of ad impressions

## 0.4.1
- Add `AdropMetrics`
- `setProperty` for setting a user property
- `logEvent` for logging custom event

## 0.4.0
- [iOS] Privacy Policy Update (Effective from May 1, 2024)

## 0.3.1
- Support adrop-ads version dynamically

## 0.3.0
- Add `AdropInterstitialAd`
- Add `AdropRewardedAd`

## 0.2.9
- AdropBannerView dispose

## 0.2.8
- flutter 3.3.0

## 0.2.7
- [Android] minSdkVersion 23
- [iOS] 13.0
- Add AdropBannerView
- Deprecated `AdropBannerController`, `AdropBanner`

## 0.2.6
- [iOS] initialize
- check production level

## 0.2.5
- API Documentation

## 0.2.3
- Support kotlin 1.7.10 or higher

## 0.2.1
- Update sdk

## 0.2.0
- Network update

## 0.1.1
- Update use ios sdk 

## 0.1.0+1
- `adrop_ads_flutter` release
