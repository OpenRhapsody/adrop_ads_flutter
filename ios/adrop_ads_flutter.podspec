#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint adrop_ads_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'adrop_ads_flutter'
  s.version          = '1.14.0'
  s.summary          = 'Adrop ads'
  s.description      = 'AdropAds flutter plugin that shows ads using native platform views'
  s.homepage         = 'https://openrhapsody.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Open Rhapsody' => 'dev@openrhapsody.com' }
  s.source           = { :path => '.' }
  # Sources live in the SPM layout (adrop_ads_flutter/Sources/adrop_ads_flutter); CocoaPods compiles the same files.
  s.source_files = 'adrop_ads_flutter/Sources/adrop_ads_flutter/**/*.swift'
  s.dependency 'Flutter'
  # Always bump together with the adrop-ads-pod version range in the SPM manifest (adrop_ads_flutter/Package.swift).
  s.dependency 'adrop-ads', '>= 1.14.0', '< 1.15.0'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
