AdropAds
========

Adrop ads plugin for flutter

[![pub package](https://img.shields.io/pub/v/adrop_ads_flutter)](https://pub.dev/packages/adrop_ads_flutter)


Prerequisites
-------------

* Install your preferred [editor or IDE](https://flutter.io/get-started/editor/).
* Make sure that your app meets the following requirements:
    * **Android**
        * Targets API level 23 (M) or higher
        * Uses Android 6.0 or higher
            * minSdkVersion 23
        * Uses [Jetpack (AndroidX)](https://developer.android.com/jetpack/androidx/migrate), which includes meeting these version requirements:
            * ```com.android.tools.build:gradle``` v7.3.0 or later
            * ```compileSdkVersion``` 33
    * **iOS**
        * ios 13.0
        * swift 5.0
* Install Flutter for your specific operating system, including the following:
    * Flutter SDK
    * Supporting libraries
    * Platform-specific software and SDKs
* [Sign into Adrop](https://adrop.io) using your email or Google account.

&nbsp;


### Step 1: Create a Adrop project
Before you can add Adrop to your Flutter app, you need to [create a Adrop project](https://docs.adrop.io/fundamentals/get-started-with-adrop#create-an-app-container) to connect to your app.

### Step 2: Register your app with Adrop
To use Adrop in your Flutter app, you need to register your app with your Adrop project. Registering your app is often called "adding" your app to your project.

> **Note**
>
> Make sure to enter the package name that your app is actually using. The package name value is case-sensitive, and it cannot be changed for this Adrop Android app after it's registered with your Adrop project.

1. Go to the Adrop console.
2. In the center of the project app page, click the **Flutter** icon button to launch the setup workflow.
3. Enter your app's package name in the **Flutter package name** field.
    * A [package name](https://developer.android.com/studio/build/application-id) uniquely identifies your app on the device and in the Google Play Store or App Store.
    * A package name is often referred to as an application ID.
    * Be aware that the package name value is case-sensitive, and it cannot be changed for this Adrop Flutter app after it's registered with your Adrop project.
4. Enter other app information: **App nickname**.
    * **App nickname**: An internal, convenience identifier that is only visible to you in the Adrop console
5. Click **Register app** and then Android and Apple apps will be created respectively.


### Step 3: Add a Adrop configuration file

#### Android
1. Download **adrop_service.json** to obtain your Adrop Android platforms config file.
2. Move your config file into your assets directory.
   ```android/app/src/main/assets/adrop_service.json```

#### iOS
1. Download **adrop_service.json** to obtain your Adrop Apple platforms config file.
2. Move your config file into the root of your Xcode project. If prompted, select to add the config file to all targets.


### Step 4: Add Adrop plugin to your app
From your Flutter project directory, run the following command to install the plugin.

```shell
flutter pub add adrop_ads_flutter
```

Install the pods, then open your .xcworkspace file to see the project in Xcode:
```shell
pod install --repo-update
```


### Step 5: Initialize Adrop in your app

The final step is to add initialization code to your application.

1. Import the Adrop plugin.
```dart
import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
```

2. Also in your ```lib/main.dart``` file, initialize Adrop.
```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    // ..
    // true for production
    // If you are using this SDK in specific countries, 
    // pass an array of ISO 3166 alpha-2 country codes.
    await Adrop.initialize(false);
  }
}


```

3. Add **AdropNavigatorObserver** to measure the frequency of ad impressions
```dart
  @override
  Widget build(BuildContext context) {
  return MaterialApp(
      navigatorObservers: [AdropNavigatorObserver()],
      ...
  );
```

4. Rebuild your Flutter application.
```shell
flutter run
```


### (Optional) Troubleshooting
```shell
# Add this line to your Podfile
use_frameworks!

# ...
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

    #...
    # Add this line to your Podfile
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

---

&nbsp;

Create your Ad unit
---

### 

From the [Adrop console](https://adrop.io/projects), go to project, then select Ad unit in the left navigation menu to create and manage Ad units. Ad units are containers you place in your apps to show ads to users. Ad units send ad requests to Adrop, then display the ads they receive to fill the request. When you create an ad unit, you assign it an ad format and ad type(s).

---


### Creating Ad units
To create a new Ad unit:
1. From the left navigation menu, select **Ad Units**.
2. Select **Create Ad unit** to bring up the ad unit builder.
3. Enter an Ad unit name, then select your app (iOS or Android) and [Ad format](https://docs.adrop.io/fundamentals/create-your-ad-unit#a-d-formats) (Banner, Interstitial, or Rewarded).
4. Select **Create** to save your Ad unit.

### Ad unit ID
The Ad unit’s unique identifier to reference in your code. This setting is read-only.

> **Note** These are unit ids for test
> * PUBLIC_TEST_UNIT_ID_320_50
> * PUBLIC_TEST_UNIT_ID_375_80
> * PUBLIC_TEST_UNIT_ID_320_100
> * PUBLIC_TEST_UNIT_ID_INTERSTITIAL
> * PUBLIC_TEST_UNIT_ID_REWARDED
> * PUBLIC_TEST_UNIT_ID_POPUP_BOTTOM
> * PUBLIC_TEST_UNIT_ID_POPUP_CENTER
> * PUBLIC_TEST_UNIT_ID_SPLASH
> * PUBLIC_TEST_UNIT_ID_NATIVE

### Display Ads
<details>
<summary style="font-size: 16px; font-weight: bold;">Banner</summary>

Initialize AdropBannerView with Ad unit ID, then load ad.
```dart
class YourComponentState extends State<YourComponent> {

  final unitId = "";
  bool isLoaded = false;
  AdropBannerView? bannerView;

  @override
  void initState() {
    super.initState();

    bannerView = AdropBannerView(
      unitId: unitId,
      listener: AdropBannerListener(
        onAdReceived: (unitId) {
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToReceive: (unitId, error) {
          setState(() {
            isLoaded = false;
          });
        },
      ),
    );
    bannerView!.load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
            onPressed: bannerView.load,
            child: const Text('Reload Ad!')),
        bannerView != null && isLoaded ?
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 80,
            child: bannerView) : Container(),
      ],
    );
  }
}
```
AdropBannerView must be disposed of when access to it is no longer needed.
```dart
@override
void dispose() {
  super.dispose();
  bannerView?.dispose();
}
```
</details>

<br>

<details>
<summary style="font-size: 16px; font-weight: bold;">Interstitial Ad</summary>

Step 1: (Optional) Construct event listener
```dart
final AdropInterstitialListener listener = AdropInterstitialListener(
    onAdReceived: (ad) =>
        debugPrint('Adrop Interstitial Ad loaded with unitId ${ad.unitId}!'),
    onAdFailedToReceive: (ad, errorCode) => 
        debugPrint('error in ${ad.unitId} while loading: $errorCode'),
    onAdFailedToShowFullScreen: (ad, errorCode) =>
        debugPrint('error in ${ad.unitId} while showing: $errorCode'),
    ...
);
```

Step 2: Display an interstitial ad
```dart
class YourComponent extends StatefulWidget {
  const YourComponent({super.key});

  @override
  State<StatefulWidget> createState() => _YourComponentState();
}

class _YourComponentState extends State<YourComponent> {
  final AdropInterstitialAd interstitialAd = AdropInterstitialAd(
    unitId: 'YOUR_UNIT_ID',
    listener: listener,
  );

  @override
  void initState() {
    super.initState();
    interstitialAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            final isLoaded = interstitialAd.isLoaded ?? false;
            if (isLoaded) {
              interstitialAd.show();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('interstitial ad is loading...'))
              );
            }
          },
          child: const Text('display ad'),
        ),
      ),
    );
  }
}
```

AdropInterstitialAd must be disposed of when access to it is no longer needed.
```dart
@override
void dispose() {
  super.dispose();
  interstitialAd.dispose();
}
```

</details>

<br>

<details>
<summary style="font-size: 16px; font-weight: bold;">Rewarded Ad</summary>

Step 1: (Optional) Construct event listener
```dart
final AdropRewardedListener listener = AdropRewardedListener(
    onAdReceived: (ad) =>
        debugPrint('Adrop Rewarded Ad loaded with unitId ${ad.unitId}!'),
    onAdFailedToReceive: (ad, errorCode) => 
        debugPrint('error in ${ad.unitId} while loading: $errorCode'),
    onAdFailedToShowFullScreen: (ad, errorCode) =>
        debugPrint('error in ${ad.unitId} while showing: $errorCode'),
    onAdEarnRewardHandler: (ad, type, amount) {
        debugPrint('Adrop Rewarded Ad earn rewards: ${ad.unitId}, $type, $amount');
        // implement your actions with rewards
    },
    ...
);
```

Step 2: Display a rewarded ad
```dart
class YourComponent extends StatefulWidget {
  const YourComponent({super.key});

  @override
  State<StatefulWidget> createState() => _YourComponentState();
}

class _YourComponentState extends State<YourComponent> {
  final AdropRewardedAd rewardedAd = AdropRewardedAd(
    unitId: 'YOUR_UNIT_ID',
    listener: listener,
  );

  @override
  void initState() {
    super.initState();
    rewardedAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            final isLoaded = rewardedAd.isLoaded ?? false;
            if (isLoaded) {
              rewardedAd.show();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('rewarded ad is loading...'))
              );
            }
          },
          child: const Text('display ad'),
        ),
      ),
    );
  }
}
```

AdropRewardedAd must be disposed of when access to it is no longer needed.
```dart
@override
void dispose() {
  super.dispose();
  rewardedAd.dispose();
}
```

</details>

<br/>

<details>
<summary style="font-size: 16px; font-weight: bold;">Popup Ad</summary>

Step 1: (Optional) Construct event listener
```dart
final AdropPopupListener listener = AdropPopupListener(
    onAdReceived: (ad) =>
        debugPrint('Adrop Popup Ad loaded with unitId ${ad.unitId}!'),
    onAdFailedToReceive: (ad, errorCode) => 
        debugPrint('error in ${ad.unitId} while loading: $errorCode'),
    onAdFailedToShowFullScreen: (ad, errorCode) =>
        debugPrint('error in ${ad.unitId} while showing: $errorCode'),
    ...
);
```

Step 2: Display a popup ad
```dart
class YourComponent extends StatefulWidget {
  const YourComponent({super.key});

  @override
  State<StatefulWidget> createState() => _YourComponentState();
}

class _YourComponentState extends State<YourComponent> {
  final AdropPopupAd popupAd = AdropPopupAd(
    unitId: 'YOUR_UNIT_ID',
    listener: listener,
  );

  @override
  void initState() {
    super.initState();
    popupAd.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            final isLoaded = popupAd.isLoaded ?? false;
            if (isLoaded) {
              popupAd.show();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('popup ad is loading...'))
              );
            }
          },
          child: const Text('display ad'),
        ),
      ),
    );
  }
}
```

AdropPopupAd must be disposed of when access to it is no longer needed.
```dart
@override
void dispose() {
  super.dispose();
  popupAd.dispose();
}
```

</details>

<br/>

<details>
<summary style="font-size: 16px; font-weight: bold;">Native Ad</summary>

Step 1: (Optional) Construct event listener
```dart
final AdropNativeListener listener = AdropNativeListener(
    onAdReceived: (ad) =>
        debugPrint('Adrop Native Ad loaded with unitId ${ad.unitId}!'),
    onAdFailedToReceive: (ad, errorCode) => 
        debugPrint('error in ${ad.unitId} while loading: $errorCode'),
    ...
);
```

Step 2: Display a native ad
```dart
class YourComponent extends StatefulWidget {
  const YourComponent({super.key});

  @override
  State<StatefulWidget> createState() => _YourComponentState();
}

class _YourComponentState extends State<YourComponent> {
  final AdropNativeAd nativeAd = AdropNativeAd(
    unitId: 'YOUR_UNIT_ID',
    listener: listener,
  );
  
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    nativeAd.load();
  }
  
  Widget nativeAdView(BuildContext context) {
    if (!isLoaded) return Container();
    
    return AdropNativeView(
      ad: nativeAd,
      child: Column(
        children: [
          if (nativeAd.properties.profile?.displayLogo)
              Image.network(
                nativeAd.properties.profile?.displayLogo,
                width: 24,
                height: 24,
              ),
          if (nativeAd.properties.profile?.displayName) 
              Text(
                nativeAd.properties.profile?.displayName,
              ),
          if (nativeAd.properties.headline != null)
            Text(nativeAd.properties.headline),
          if (nativeAd.properties.body != null)
            Text(nativeAd.properties.body),
          if (nativeAd.properties.asset != null)
            Image.network(nativeAd.properties.asset, width: {{yourWidth}}, height: {{yourHeight}}),
          if (nativeAd.properties.extra['sampleExtraId'] != null)
            Text(nativeAd.properties.extra['sampleExtraId']),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: nativeAdView(context),
      ),
    );
  }
}
```

</details>
