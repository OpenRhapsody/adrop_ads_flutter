/// Impression-level ad revenue for a single backfill impression.
///
/// Delivered together with the ad that earned it, so read `unitId`, `txId` and friends
/// from that ad rather than from here.
///
/// Adrop direct ads never fire this. The value is the ad provider's own gross estimate,
/// not a settlement figure.
class AdropAdValue {
  /// Backfill provider that served the ad, e.g. `'admob'`.
  final String network;

  /// Mediation ad source inside the provider (e.g. `'AppLovin'`), null when unknown.
  final String? adSourceName;

  /// Revenue in 1/1,000,000 of [currencyCode].
  final int valueMicros;

  /// ISO 4217 currency code, passed through from the provider.
  final String currencyCode;

  /// How accurate [valueMicros] is.
  final AdropAdValuePrecision precision;

  const AdropAdValue({
    required this.network,
    this.adSourceName,
    required this.valueMicros,
    required this.currencyCode,
    required this.precision,
  });

  /// [valueMicros] in whole currency units. Use [valueMicros] for arithmetic.
  double get value => valueMicros / 1000000.0;

  factory AdropAdValue.fromMap(Map map) {
    return AdropAdValue(
      network: map['network'] ?? '',
      adSourceName: map['adSourceName'],
      valueMicros: map['valueMicros'] ?? 0,
      currencyCode: map['currencyCode'] ?? '',
      precision: AdropAdValuePrecision.fromName(map['precision']),
    );
  }

  @override
  String toString() {
    final source = adSourceName != null ? '/$adSourceName' : '';
    return 'AdropAdValue($value $currencyCode, $precision, $network$source)';
  }
}

/// Accuracy of [AdropAdValue.valueMicros]. Mirrors AdMob's four precision types.
enum AdropAdValuePrecision {
  /// Not enough data to report a meaningful value.
  unknown,

  /// Estimated from aggregated data.
  estimated,

  /// A publisher-provided value, such as a manual CPM in a mediation group.
  publisherProvided,

  /// The precise amount paid for this impression.
  precise;

  /// Parses the wire name sent by both native bridges; anything unexpected is [unknown].
  static AdropAdValuePrecision fromName(dynamic name) {
    switch (name) {
      case 'estimated':
        return AdropAdValuePrecision.estimated;
      case 'publisherProvided':
        return AdropAdValuePrecision.publisherProvided;
      case 'precise':
        return AdropAdValuePrecision.precise;
      default:
        return AdropAdValuePrecision.unknown;
    }
  }
}
