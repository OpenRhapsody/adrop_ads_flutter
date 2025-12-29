/// Debug geography settings for testing consent
enum AdropConsentDebugGeography {
  /// Debug settings disabled (use actual location)
  disabled(0),

  /// European Economic Area (GDPR applies)
  eea(1),

  /// Regulated US state (California, etc., CCPA applies)
  regulatedUSState(3),

  /// Regions without regulations
  other(4);

  final int value;

  const AdropConsentDebugGeography(this.value);

  static AdropConsentDebugGeography fromValue(int value) {
    return AdropConsentDebugGeography.values.firstWhere(
      (geography) => geography.value == value,
      orElse: () => AdropConsentDebugGeography.disabled,
    );
  }
}
