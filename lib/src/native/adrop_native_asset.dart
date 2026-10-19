/// A single media slot of a native ad (a value of `AdropNativeProperties.extraAssets`, keyed by [id]).
/// Created by the SDK and read-only for publishers. Rendering and tracking each slot is up to the publisher.
class AdropNativeAsset {
  final String id;

  final String asset;

  final String creative;

  final String? cover;

  /// Media type of the slot, `'display'` | `'video'` (server `type`). Null for responses from older servers.
  final String? type;

  /// Uses [type] when the server sends it. Otherwise (legacy responses) inferred from [cover] and the file extension.
  final bool isVideo;

  const AdropNativeAsset({
    required this.id,
    required this.asset,
    required this.creative,
    this.cover,
    this.type,
    required this.isVideo,
  });
}
