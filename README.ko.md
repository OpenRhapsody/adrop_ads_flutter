# Adrop Ads Example - Flutter

Flutter에서 [Adrop Ads SDK](https://adrop.io)를 연동하는 예제 앱입니다.

[![pub package](https://img.shields.io/pub/v/adrop_ads_flutter)](https://pub.dev/packages/adrop_ads_flutter)
[![pub points](https://img.shields.io/pub/points/adrop_ads_flutter)](https://pub.dev/packages/adrop_ads_flutter/score)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20Android-blue)](https://pub.dev/packages/adrop_ads_flutter)
[![License](https://img.shields.io/github/license/OpenRhapsody/adrop_ads_flutter)](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/LICENSE)

Language: [English](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/README.md) | 한국어

## 시작하기

- [Adrop 콘솔](https://console.adrop.io) - 앱 등록 및 광고 단위 ID 발급
- [Adrop 개발자 문서](https://docs.adrop.io/ko/sdk/flutter) - SDK 연동 및 고급 기능
- [테스트 광고 단위 ID](https://docs.adrop.io/ko/sdk#테스트-환경) - 개발 중 테스트용 ID

## 예제

### Adrop Ads

| 광고 형식   | 예제 |
|---------|------|
| 배너      | [banner_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/banner_example.dart) |
| 전면      | [interstitial_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/interstitial_example.dart) |
| 보상형     | [rewarded_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/rewarded_example.dart) |
| 팝업      | [popup_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/popup_example.dart) |
| 네이티브    | [native_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/native_example.dart) |

### 타겟팅

|          | 예제 |
|----------|------|
| 속성 & 이벤트 | [property_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/property_example.dart) |

### 개인정보 & 동의

> **참고**: 동의 관리 기능은 [AdropAdsBackfill](https://docs.adrop.io/ko/sdk/flutter/backfill) 모듈이 필요합니다.

|                   | 예제 |
|-------------------|------|
| 동의 관리 (GDPR/CCPA) | [consent_example.dart](https://github.com/OpenRhapsody/adrop_ads_flutter/blob/master/example/lib/views/consent_example.dart) |

## 실행 방법

### 1. 저장소 클론

```bash
git clone https://github.com/OpenRhapsody/adrop_ads_flutter.git
```

### 2. example 디렉토리로 이동

```bash
cd adrop_ads_flutter/example
```

### 3. 의존성 설치

```bash
flutter pub get
```

### 4. 설정 파일 추가

[Adrop 콘솔](https://adrop.io)에서 `adrop_service.json`을 다운로드하고 다음 경로에 배치합니다:

#### Android
```
android/app/src/main/assets/adrop_service.json
```

#### iOS
> **중요**: iOS의 경우, `adrop_service.json`을 Xcode를 통해 추가해야 합니다.
>
> 1. Xcode에서 `ios/Runner.xcworkspace`를 엽니다
> 2. `Runner` 폴더를 우클릭하고 "Add Files to Runner..."를 선택합니다
> 3. `adrop_service.json`을 선택하고 "Copy items if needed"가 체크되어 있는지 확인합니다
> 4. 파일이 Runner 타겟에 추가되었는지 확인합니다

### 5. iOS 의존성 설치

```bash
cd ios && pod install && cd ..
```

### 6. 빌드 및 실행

```bash
flutter run
```
