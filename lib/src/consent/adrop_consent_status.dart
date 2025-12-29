/// User consent status
enum AdropConsentStatus {
  /// Not yet determined
  unknown(0),

  /// Consent is required (popup needs to be shown)
  required(1),

  /// Consent is not required (not in the applicable region)
  notRequired(2),

  /// Consent has been obtained
  obtained(3);

  final int value;

  const AdropConsentStatus(this.value);

  static AdropConsentStatus fromValue(int value) {
    return AdropConsentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AdropConsentStatus.unknown,
    );
  }
}
