enum AdropErrorCode {
  /// The network status is unstable.
  network("ERROR_CODE_NETWORK"),

  /// Error in sdk
  internal("ERROR_CODE_INTERNAL"),

  /// Before Adrop initialize
  initialize("ERROR_CODE_INITIALIZE"),

  /// Ad unit ID is not valid.
  invalidUnit("ERROR_CODE_INVALID_UNIT"),

  /// There are no active advertising campaigns.
  inactive("ERROR_CODE_AD_INACTIVE"),

  /// Unable to receive ads that meet the criteria. Please retry.
  adNoFill("ERROR_CODE_AD_NO_FILL"),

  /// undefined code
  undefined("UNDEFINED");

  final String code;

  const AdropErrorCode(this.code);

  factory AdropErrorCode.getByCode(String code) {
    return AdropErrorCode.values.firstWhere(
      (value) => value.code == code,
      orElse: () => AdropErrorCode.undefined,
    );
  }
}
