enum BrowserTarget {
  external, // 0
  internal; // 1

  static BrowserTarget? fromOrdinal(int? ordinal) {
    if (ordinal == null) return null;
    if (ordinal < 0 || ordinal >= BrowserTarget.values.length) return null;
    return BrowserTarget.values[ordinal];
  }
}
