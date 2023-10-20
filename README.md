AdropAds
========

Adrop ads plugin for flutter


Prerequisites
-------------
  - Flutter 3.3.0 or higher
  - Android
    - Android Studio 3.2 or higher
    - minSdkVersion 24
    - compileSdkVersion 33
  - iOS
    - Latest version of Xcode with enabled command-line tools
    - Swift 5.0
    - ios 14.0

Getting Started
---------------

Before you can display ads in your app, you'll need to create an [Adrop](https://adrop.io) account. 

### 1. Add dependency
```agsl
flutter pub add adrop_ads_flutter
```

### 2. Add adrop_service.json

Get ***adrop_service.json*** from [Adrop](https://adrop.io), add to android/ios
(Use different ***adrop_service.json*** files for each platform.)

Android
> android/app/src/main/assets/adrop_service.json

iOS
> ios/Runner/adrop_service.json

### 3. Initialize AdropAds
```dart
import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';

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
    let production = false;  // TODO set true for production mode 
    await AdropAdsFlutter.initialize(production);
  }
}
```

### 5. Load Ads
```dart
class YourComponent extends StatelessWidget {
  late final AdropBannerController _bannerController;
  final String unitId = ""; // TODO replace your unitId

  void _onAdropBannerCreated(AdropBannerController controller) {
    _bannerController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Column(
        children: [
          TextButton(
              onPressed: () {
                _bannerController.load();
              },
              child: const Text('Request Ad!')),
          SizedBox(
            width: screenWidth,
            height: 80,
            child: AdropBanner(
              onAdropBannerCreated: _onAdropBannerCreated,
              unitId: unitId,
              adSize: AdropBannerSize.h80,
              onAdClicked: () {
                debugPrint("onAdClicked");
              },
              onAdReceived: () {
                debugPrint("onAdReceived");
              },
              onAdFailedToReceive: (code) {
                debugPrint("onAdFailedToReceive: $code");
              },
            ),
          )
        ]);
  }
}
```
