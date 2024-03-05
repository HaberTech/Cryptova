import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'package:cryptova/backend/adunits.dart';
import 'package:cryptova/backend/ads.dart' show AnchoredAdaptiveExample;

class CryptovaUpdatesSection extends StatefulWidget {
  const CryptovaUpdatesSection({super.key});

  @override
  State<CryptovaUpdatesSection> createState() => _CryptovaUpdatesSectionState();
}

class _CryptovaUpdatesSectionState extends State<CryptovaUpdatesSection> {
  bool _isLoading = true;
  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    super.initState();
    _loadWebView();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        children: <Widget>[
          Expanded(
            child: WebViewWidget(
              controller: _webViewController,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer(),
                ),
              }.toSet(),
            ),
          ),
          AnchoredAdaptiveExample(
            adUnitId: AdUnits.bannerForUpdates,
          ),
        ],
      );
    }
  }

  void _loadWebView() {
    // The controller is initialized in the onWebViewCreated callback
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            // Update state to indicate that the page has finished loading.
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            // Handle the error here
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith(
                'https://apps.habertech.info/2024/02/offer-of-day.html')) {
              return NavigationDecision.navigate;
            }
            url_launcher.launchUrl(Uri.parse(request.url));
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            'https://apps.habertech.info/2024/02/offer-of-day.html?m=1&theme=auto'),
      );
  }
}
