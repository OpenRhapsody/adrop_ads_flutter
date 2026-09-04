import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';

import '../constants/adrop_unit_id.dart';

/// Batch loads() Example
///
/// Demonstrates loading up to 5 banners / native ads with a single network
/// request ([AdropBannerView.loads] / [AdropNativeAd.loads]) and mounting
/// them in a scrolling feed. Filler rows are interleaved so scrolling
/// off-screen and back exercises the re-attach contract (unmount only
/// detaches; the instance lives until dispose()).
class LoadsExample extends StatefulWidget {
  const LoadsExample({Key? key}) : super(key: key);

  @override
  State createState() => _LoadsExampleState();
}

class _LoadsExampleState extends State<LoadsExample> {
  List<AdropBannerView> banners = [];
  List<AdropNativeAd> nativeAds = [];
  String status = 'Idle';
  bool cancelled = false;

  @override
  void dispose() {
    // Publisher owns cleanup: every batch-delivered instance holds a native
    // WebView (~5-15 MB) and must be disposed — including never-mounted ones.
    cancelled = true;
    for (final banner in banners) {
      banner.dispose();
    }
    for (final ad in nativeAds) {
      ad.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBanners() async {
    try {
      final loaded = await AdropBannerView.loads(
        unitId: AdropUnitId.bannerImage320x100,
        listener: AdropBannerListener(
          // One listener for all slots — metadata['requestId'] tells them apart.
          onAdClicked: (unitId, metadata) =>
              debugPrint('banner clicked: ${metadata?['requestId']}'),
          onAdImpression: (unitId, metadata) =>
              debugPrint('banner impression: ${metadata?['requestId']}'),
        ),
      );
      // The screen may have been closed while loading — dispose immediately.
      if (cancelled) {
        for (final banner in loaded) {
          banner.dispose();
        }
        return;
      }
      setState(() {
        for (final banner in banners) {
          banner.dispose();
        }
        banners = loaded;
        status = 'Banners: ${loaded.length} received';
      });
    } on Exception catch (e) {
      if (!cancelled) setState(() => status = 'Banner loads failed: $e');
    }
  }

  Future<void> _loadNativeAds() async {
    try {
      final loaded = await AdropNativeAd.loads(
        unitId: AdropUnitId.native,
        listener: AdropNativeListener(
          onAdClicked: (ad) => debugPrint('native clicked: ${ad.creativeId}'),
          onAdImpression: (ad) =>
              debugPrint('native impression: ${ad.creativeId}'),
        ),
      );
      if (cancelled) {
        for (final ad in loaded) {
          ad.dispose();
        }
        return;
      }
      setState(() {
        for (final ad in nativeAds) {
          ad.dispose();
        }
        nativeAds = loaded;
        status = 'Native ads: ${loaded.length} received';
      });
    } on Exception catch (e) {
      if (!cancelled) setState(() => status = 'Native loads failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = _buildFeedItems();
    return Scaffold(
      appBar: AppBar(title: const Text('Batch loads()')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadBanners,
                    child: const Text('Load 5 Banners'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loadNativeAds,
                    child: const Text('Load 5 Native'),
                  ),
                ),
              ],
            ),
          ),
          Text(status, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: feed.length,
              itemBuilder: (context, index) => feed[index],
            ),
          ),
        ],
      ),
    );
  }

  /// Interleaves ads with filler rows so long scrolls unmount/remount them.
  List<Widget> _buildFeedItems() {
    final items = <Widget>[];
    final ads = <Widget>[
      for (final banner in banners)
        SizedBox(
          height: banner.creativeSize?.height ?? 80,
          child: banner,
        ),
      for (final ad in nativeAds) _nativeCard(ad),
    ];

    var adIndex = 0;
    for (var i = 0; i < (ads.isEmpty ? 10 : ads.length * 4); i++) {
      if (i % 4 == 2 && adIndex < ads.length) {
        items.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: ads[adIndex++],
        ));
      } else {
        items.add(ListTile(
          leading: const Icon(Icons.article_outlined),
          title: Text('Feed item $i'),
          subtitle: const Text('Scroll past the ads and back to re-attach'),
        ));
      }
    }
    return items;
  }

  Widget _nativeCard(AdropNativeAd ad) {
    return AdropNativeAdView(
      // Key the ad view by requestId: platform views freeze their creationParams
      // at creation, so a keyless widget reused at the same list position after
      // a second loads() would keep rendering the previous ad.
      key: ValueKey(ad.requestId),
      ad: ad,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ad.properties.headline ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(ad.properties.body ?? ''),
              if (ad.properties.callToAction?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () => debugPrint('CTA tapped'),
                    child: Text(ad.properties.callToAction ?? ''),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
