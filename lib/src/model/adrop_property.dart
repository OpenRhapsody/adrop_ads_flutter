/// Type of Adrop value
typedef AdropValue = String;

/// Keys for Adrop properties
enum AdropProperties {
  age("AGE"),

  /// Birth property for yyyy, yyyyMM, yyyyMMdd format
  birth("BIRTH"),

  /// Gender property for AdropGender
  gender("GDR");

  final String code;

  const AdropProperties(this.code);
}

/// Values for gender
enum AdropGender {
  male("M"),
  female("F"),
  other("O"),
  unknown("U");

  final String code;

  const AdropGender(this.code);
}
