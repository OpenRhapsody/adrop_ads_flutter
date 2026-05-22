/// Preferred display position of the AdChoices icon on AdMob backfill native ads.
///
/// - This is a *preferred position hint* forwarded to backfill networks such as
///   AdMob; the network may enforce a different position per its policy.
/// - Not applied on the direct (Adrop) ad path — direct ad creatives are HTML
///   and the AdChoices icon concept is AdMob-specific.
/// - The default [topRight] matches the AdMob SDK default.
enum AdropAdChoicesPosition {
  /// Top-left.
  topLeft(0),

  /// Top-right (default).
  topRight(1),

  /// Bottom-left.
  bottomLeft(2),

  /// Bottom-right.
  bottomRight(3);

  final int value;
  const AdropAdChoicesPosition(this.value);
}
