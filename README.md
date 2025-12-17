# Adrop Ads - Flutter

Adrop ads plugin for Flutter

[![pub package](https://img.shields.io/pub/v/adrop_ads_flutter)](https://pub.dev/packages/adrop_ads_flutter)
[![pub points](https://img.shields.io/pub/points/adrop_ads_flutter)](https://pub.dev/packages/adrop_ads_flutter/score)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)](https://pub.dev/packages/adrop_ads_flutter)
[![License](https://img.shields.io/github/license/OpenRhapsody/adrop_ads_flutter)](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/LICENSE)

Language: English | [한국어](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/README.ko.md)

## Getting Started

- [Adrop Console](https://console.adrop.io) - Register your app and issue ad unit IDs
- [Adrop Developer Docs](https://docs.adrop.io/sdk/flutter) - SDK integration and advanced features
- [Test Ad Unit IDs](https://docs.adrop.io/sdk#test-environment) - Use test IDs during development

## Examples

### Adrop Ads

| Ad Format | Example |
|-----------|---------|
| Banner | [banner_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/banner_example.dart) |
| Interstitial | [interstitial_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/interstitial_example.dart) |
| Rewarded | [rewarded_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/rewarded_example.dart) |
| Popup | [popup_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/popup_example.dart) |
| Native | [native_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/native_example.dart) |

### Targeting

| Feature | Example |
|---------|---------|
| Property & Event | [property_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/property_example.dart) |

## How to Run Examples

### 1. Clone the repository

```bash
git clone https://github.com/OpenRhapsody/adrop_ads_flutter.git
```

### 2. Navigate to the example directory

```bash
cd adrop_ads_flutter/example
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Add configuration file

Download `adrop_service.json` from [Adrop Console](https://adrop.io) and place it in:

#### Android
```
android/app/src/main/assets/adrop_service.json
```

#### iOS
> **Important**: For iOS, you must add `adrop_service.json` through Xcode.
>
> 1. Open `ios/Runner.xcworkspace` in Xcode
> 2. Right-click on the `Runner` folder and select "Add Files to Runner..."
> 3. Select `adrop_service.json` and ensure "Copy items if needed" is checked
> 4. Make sure the file is added to the Runner target

### 5. Install iOS dependencies

```bash
cd ios && pod install && cd ..
```

### 6. Build and run

```bash
flutter run
```
