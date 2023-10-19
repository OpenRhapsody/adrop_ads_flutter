import 'package:adrop_ads_flutter/banner/adrop_banner_size.dart';

class CallCreateBanner {
  final String unitId;
  final AdropBannerSize adSize;

  CallCreateBanner({required this.unitId, required this.adSize});

  CallCreateBanner.fromJson(Map<String, dynamic> json)
      : this(
          unitId: json['unitId'] as String? ?? "",
          adSize: AdropBannerSize.getById(json['adSize'] as String? ?? ""),
        );

  Map<String, dynamic> toJson() => {
        'unitId': unitId,
        'adSize': adSize.id,
      };
}
