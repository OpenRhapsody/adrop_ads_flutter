import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The iOS native SDK (`adrop-ads`) dependency range is declared in **two places**.
///
/// * CocoaPods: `ios/adrop_ads_flutter.podspec`
/// * SPM:       `ios/adrop_ads_flutter/Package.swift`
///
/// Both compile the same sources, so a mismatch breaks only one set of publishers — if the SPM
/// path pulls in an older core, files referencing newer APIs (`AdropAdValue` and friends) fail to
/// compile **in the publisher's build**. Our CI does not catch that.
///
/// It actually happened while preparing 1.13.0: only the podspec was bumped and the two drifted
/// apart for a whole release. A "bump them together" comment did not prevent it, so it is a test
/// instead.
void main() {
  test('podspec and Package.swift declare the same adrop-ads version range',
      () {
    final podspec = File('ios/adrop_ads_flutter.podspec').readAsStringSync();
    final packageSwift =
        File('ios/adrop_ads_flutter/Package.swift').readAsStringSync();

    // s.dependency 'adrop-ads', '>= 1.13.0', '< 1.14.0'
    final podMatch = RegExp(
      r"""s\.dependency\s+'adrop-ads',\s*'>=\s*([0-9.]+)',\s*'<\s*([0-9.]+)'""",
    ).firstMatch(podspec);
    expect(podMatch, isNotNull,
        reason:
            'Could not find the adrop-ads dependency range in the podspec — if the format changed, fix this test too');

    // .package(url: "...adrop-ads-pod.git", "1.13.0" ..< "1.14.0")
    final spmMatch = RegExp(
      r'adrop-ads-pod\.git",\s*"([0-9.]+)"\s*\.\.<\s*"([0-9.]+)"',
    ).firstMatch(packageSwift);
    expect(spmMatch, isNotNull,
        reason:
            'Could not find the adrop-ads-pod version range in Package.swift');

    expect(
      '${spmMatch!.group(1)}..<${spmMatch.group(2)}',
      '${podMatch!.group(1)}..<${podMatch.group(2)}',
      reason:
          'The CocoaPods and SPM native SDK ranges have drifted apart — bump them together',
    );
  });
}
