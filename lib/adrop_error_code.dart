enum AdropErrorCode {
  network("ERROR_CODE_NETWORK"),
  internal("ERROR_CODE_INTERNAL"),
  initialize("ERROR_CODE_INITIALIZE"),
  invalidUnit("ERROR_CODE_INVALID_UNIT"),
  inactive("ERROR_CODE_AD_INACTIVE"),
  adNoFill("ERROR_CODE_AD_NO_FILL"),
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
