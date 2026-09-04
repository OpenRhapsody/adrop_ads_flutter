import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:adrop_ads_flutter/src/utils/id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../bridge/adrop_channel.dart';
import '../model/call_create_ad.dart';
import '../utils/loads_batch.dart';
import 'adrop_ad_manager.dart';

// ignore: must_be_immutable
class AdropBannerView extends StatelessWidget {
  final String unitId;

  final AdropBannerListener? listener;

  /// Optional fixed size for the banner view (width, height)
  Size? adSize;

  final String _requestId;

  CreativeSize? get creativeSize =>
      adropAdManager.getCreativeSize(this, _requestId);

  /// Identifies this banner instance. With [loads] the same unitId can fill
  /// multiple slots — compare the `requestId` entry in a listener callback's
  /// metadata against this value to tell which slot fired.
  String get requestId => _requestId;

  /// Banner view class responsible for displaying banner ads to the user.
  ///
  /// [unitId] required Ad unit ID
  /// [listener] optional invoked when the banner received, failed to receive and clicked
  AdropBannerView({super.key, required this.unitId, this.listener})
      : _requestId = nanoid();

  /// Wraps a banner already loaded natively by [loads]; binds this widget to
  /// the pre-assigned [requestId] instead of minting a new one.
  ///
  /// Keyed by requestId: PlatformViewLink/UiKitView freeze their
  /// creationParams when the platform view is created, so a keyless widget
  /// reused at the same list position (e.g. a second loads() replacing the
  /// list) would keep rendering the previous — already disposed — banner.
  /// The key forces the element to be recreated instead.
  AdropBannerView._preloaded(
      {required this.unitId, required String requestId, this.listener})
      : _requestId = requestId,
        super(key: ValueKey(requestId));

  /// Loads up to 5 banners with a single network request and returns them as
  /// ready-to-mount widgets. Do NOT call [load] on the returned widgets — they
  /// are already loaded (a second load would issue another network request).
  ///
  /// The returned widgets are re-attachable: unmounting (e.g. a ListView
  /// recycling an off-screen item) only detaches the native view, and
  /// remounting re-binds it. The native banner lives until you call [dispose]
  /// on it — each returned widget owns a WebView (~5-15 MB), so dispose every
  /// one of them when the screen goes away, even those never mounted.
  ///
  /// [listener] is shared by all returned banners; use the `requestId` entry
  /// in the callback metadata (see [requestId]) to tell slots apart.
  ///
  /// Throws a [PlatformException] whose `code` is an [AdropErrorCode] name
  /// (e.g. `ERROR_CODE_AD_NO_FILL` when nothing filled).
  static Future<List<AdropBannerView>> loads({
    required String unitId,
    AdropBannerListener? listener,
  }) async {
    final requestIds = List.generate(maxLoadsBatch, (_) => nanoid());
    final response =
        await adropAdManager.invokeLoadsBanners(unitId, requestIds);
    final map = response is Map ? response : const {};
    final filledIds = (map['requestIds'] as List?)?.cast<String>() ?? const [];
    final metas = map['ads'] as List? ?? const [];

    final views = <AdropBannerView>[];
    for (var i = 0; i < filledIds.length; i++) {
      final view = AdropBannerView._preloaded(
        unitId: unitId,
        requestId: filledIds[i],
        listener: listener,
      );
      adropAdManager.registerPreloadedBanner(
          view, filledIds[i], i < metas.length ? metas[i] as Map? : null);
      views.add(view);
    }
    return views;
  }

  @override
  Widget build(BuildContext context) {
    final creationParams = CallCreateAd(unitId: unitId, requestId: _requestId);

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return PlatformViewLink(
            viewType: AdropChannel.bannerEventListenerChannel,
            surfaceFactory: (context, controller) {
              return AndroidViewSurface(
                controller: controller as AndroidViewController,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                      () => PanGestureRecognizer())
                },
                hitTestBehavior: PlatformViewHitTestBehavior.opaque,
              );
            },
            onCreatePlatformView: (params) {
              return PlatformViewsService.initSurfaceAndroidView(
                id: params.id,
                viewType: AdropChannel.bannerEventListenerChannel,
                layoutDirection: TextDirection.ltr,
                creationParams: creationParams.toJson(),
                creationParamsCodec: const StandardMessageCodec(),
              )
                ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
                ..create();
            });
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: AdropChannel.bannerEventListenerChannel,
          creationParams: creationParams.toJson(),
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: (_) {},
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(() => PanGestureRecognizer())
          },
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      default:
        return Text('$defaultTargetPlatform is not yet supported');
    }
  }

  /// Requests an ad from Adrop using the Ad unit ID of the AdropBannerView.
  Future<void> load() async {
    return await adropAdManager.load(this, _requestId);
  }

  /// Invoked when dispose() is called on the corresponding AdropBannerView
  Future<void> dispose() async {
    return await adropAdManager.dispose(this, _requestId);
  }

  /// Starts or resumes playback of the video banner ad.
  Future<void> play() async {
    return await adropAdManager.play(this, _requestId);
  }

  /// Pauses playback of the video banner ad.
  Future<void> pause() async {
    return await adropAdManager.pause(this, _requestId);
  }
}
