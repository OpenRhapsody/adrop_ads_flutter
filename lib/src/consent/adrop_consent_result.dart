import 'adrop_consent_status.dart';

/// Consent request result
class AdropConsentResult {
  /// Consent status
  final AdropConsentStatus status;

  /// Whether ads can be requested (core value)
  final bool canRequestAds;

  /// Whether personalized ads can be shown
  final bool canShowPersonalizedAds;

  /// Error message (if any)
  final String? error;

  AdropConsentResult({
    required this.status,
    required this.canRequestAds,
    required this.canShowPersonalizedAds,
    this.error,
  });

  factory AdropConsentResult.fromMap(Map<dynamic, dynamic> map) {
    return AdropConsentResult(
      status: AdropConsentStatus.fromValue(map['status'] as int? ?? 0),
      canRequestAds: map['canRequestAds'] as bool? ?? false,
      canShowPersonalizedAds: map['canShowPersonalizedAds'] as bool? ?? false,
      error: map['error'] as String?,
    );
  }

  @override
  String toString() {
    return 'AdropConsentResult(status: $status, canRequestAds: $canRequestAds, canShowPersonalizedAds: $canShowPersonalizedAds, error: $error)';
  }
}
