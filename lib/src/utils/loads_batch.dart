/// Upper bound on ads returned from a single batch `loads()` call.
///
/// Mirror of the native SDKs' cap (`AdropBanner.MAX_LOADS_BATCH` /
/// `AdropNativeAd.maxLoadsBatch` — both 5). The native constant is the SSOT;
/// this mirror exists because the Android constant is `internal` (not visible
/// to this plugin) and requestIds must be minted synchronously before the
/// native call. If the native cap ever grows, the only effect here is
/// receiving fewer ads than the server returned (safe under-consumption).
const int maxLoadsBatch = 5;
