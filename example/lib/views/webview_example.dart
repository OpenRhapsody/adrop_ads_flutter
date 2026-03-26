import 'dart:io';

import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../theme/colors.dart';

const _testUrl = 'https://google.github.io/webview-ads/test/';

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  late final WebViewController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();

    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    _registerAndLoad();
  }

  Future<void> _registerAndLoad() async {
    final int identifier;
    if (Platform.isAndroid) {
      identifier =
          (_controller.platform as AndroidWebViewController).webViewIdentifier;
    } else if (Platform.isIOS) {
      identifier =
          (_controller.platform as WebKitWebViewController).webViewIdentifier;
    } else {
      return;
    }

    await Adrop.registerWebView(identifier);

    setState(() => _isReady = true);
    _controller.loadRequest(Uri.parse(_testUrl));
  }

  void _reload() {
    _controller.loadRequest(Uri.parse(_testUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('WebView Register Test'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AdropColors.surface,
              border: Border(
                bottom: BorderSide(color: AdropColors.divider),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isReady ? 'Registered' : 'Registering WebView...',
                    style: TextStyle(
                      fontSize: 13,
                      color: _isReady
                          ? AdropColors.success
                          : AdropColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdropColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onPressed: _reload,
                  child: const Text('Reload', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isReady
                ? WebViewWidget(controller: _controller)
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }
}
