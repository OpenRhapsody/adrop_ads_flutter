enum AdropErrorCode {
  /// The network status is unstable.
  network("ERROR_CODE_NETWORK"),

  /// Error in sdk.
  internal("ERROR_CODE_INTERNAL"),

  /// Before Adrop initialize.
  initialize("ERROR_CODE_INITIALIZE"),

  /// Ad unit ID is not valid.
  invalidUnit("ERROR_CODE_INVALID_UNIT"),

  /// Unable to use SDK when the device country is not supported.
  notTargetCountry("ERROR_CODE_NOT_TARGET_COUNTRY"),

  /// There are no active advertising campaigns.
  inactive("ERROR_CODE_AD_INACTIVE"),

  /// Unable to receive ads that meet the criteria. Please retry.
  adNoFill("ERROR_CODE_AD_NO_FILL"),

  /// Unable to load again after ad received.
  adLoadDuplicate("ERROR_CODE_AD_LOAD_DUPLICATED"),

  /// Unable to load again before ad received
  adLoading("ERROR_CODE_AD_LOADING"),

  /// Unable to show ad before ad received
  adEmpty("ERROR_CODE_AD_EMPTY"),

  /// Unable to show ad again
  adShown("ERROR_CODE_AD_SHOWN"),

  /// Unable to load ad for today
  adHideForToday("ERROR_CODE_AD_HIDE_FOR_TODAY"),

  /// Account usage limit exceeded
  accountUsageLimitExceeded("ERROR_CODE_ACCOUNT_USAGE_LIMIT_EXCEEDED"),

  /// Unable to display ad in landscape mode
  adLandscapeUnsupported("ERROR_CODE_LANDSCAPE_UNSUPPORTED"),

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
