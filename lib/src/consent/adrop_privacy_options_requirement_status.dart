/// Whether a privacy options (privacy settings) entry point must be shown
enum AdropPrivacyOptionsRequirementStatus {
  /// Not yet determined — requestConsentInfoUpdate has not completed in this
  /// app session, or the installed backfill does not support privacy options
  unknown(0),

  /// An entry point to change privacy options must be shown
  required(1),

  /// No entry point is needed
  notRequired(2);

  final int value;

  const AdropPrivacyOptionsRequirementStatus(this.value);

  static AdropPrivacyOptionsRequirementStatus fromValue(int value) {
    return AdropPrivacyOptionsRequirementStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AdropPrivacyOptionsRequirementStatus.unknown,
    );
  }
}
