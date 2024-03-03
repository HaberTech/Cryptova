import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

export 'package:google_mobile_ads/google_mobile_ads.dart';

// /* EMPTY ADS */
// class InterstitialAdExample {
//   final String adUnitId;
//   int countsSinceLastShow = 0;

//   InterstitialAdExample({required this.adUnitId});

//   void addToCountsSinceLastShow({int countsToAdd = 1}) {
//     countsSinceLastShow += countsToAdd;
//   }

//   void showAd() {
//     debugPrint('Test InterstitialAdExample: showAd()');
//   }

//   void dispose() {
//     debugPrint('Test InterstitialAdExample: dispose()');
//   }
// }

// class NativeExample extends StatelessWidget {
//   final TemplateType templateType;
//   final String adUnitId;

//   const NativeExample({
//     super.key,
//     required this.templateType,
//     required this.adUnitId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox();
//   }
// }

// class AnchoredAdaptiveExample extends StatelessWidget {
//   final String adUnitId;

//   const AnchoredAdaptiveExample({super.key, required this.adUnitId});

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox();
//   }
// }

// class InlineAdaptiveExample extends StatelessWidget {
//   final String adUnitId;

//   const InlineAdaptiveExample({super.key, required this.adUnitId});

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox();
//   }
// }
// /* EMPTY ADS */

/* Real Ads */
// INTERESTIAL AD
class InterstitialAdExample {
  final String adUnitId;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  int _countsSinceLastShow = 0;
  InterstitialAd? _interstitialAd;

  // Get the counts since last show
  int get countsSinceLastShow => _countsSinceLastShow;

  // CONSTRUCTOR: Load ad on creation
  InterstitialAdExample({required this.adUnitId}) {
    _loadAd();
  }

// Add to the counter for last seen ad. By default add 1
  int addToCountsSinceLastShow({int countsToAdd = 1}) {
    _countsSinceLastShow += countsToAdd;
    return _countsSinceLastShow;
  }

  // DISPOSE THE AD AND LOAD A NEW ONE
  void _disposeAdAndLoadNew(InterstitialAd ad) {
    ad.dispose();
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdLoaded = false;
    _loadAd();
  }

  // set callbacks for after the ad loads
  void _declareFullScreenContentCalleback() {
    _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
        // Called when the ad showed the full screen content.
        onAdShowedFullScreenContent: (ad) {
          debugPrint('$ad onAdShowedFullScreenContent.');
          _countsSinceLastShow = 0; // Reset the counter
        },
        // Called when an impression occurs on the ad.
        onAdImpression: (ad) {},
        // Called when the ad failed to show full screen content.
        onAdFailedToShowFullScreenContent: (ad, err) {
          debugPrint('$ad onAdFailedToShowFullScreenContent: $err');
          _disposeAdAndLoadNew(ad);
        },
        // Called when the ad dismissed full screen content.
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('$ad onAdDismissedFullScreenContent.');
          _disposeAdAndLoadNew(ad);
        },
        // Called when a click is recorded for an ad.
        onAdClicked: (ad) {});
  }

  /// Loads an interstitial ad.
  void _loadAd() {
    if (_isAdLoaded || _isAdLoading) {
      return;
    }
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          // Ad is loaded and no other ad is loading
          _isAdLoaded = true;
          _isAdLoading = false;
          // Keep a reference to the ad so you can show it later.
          _interstitialAd = ad;
          _declareFullScreenContentCalleback();
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
        },
        // Called when the ad dismissed full screen content.
      ),
    );
    _isAdLoading = true;
  }

  // Shows an interstitial ad.
  void showAd() {
    if (_interstitialAd != null && _isAdLoaded) {
      _interstitialAd?.show();
    } else {
      debugPrint('Interstitial ad is not ready yet.');
      _loadAd();
    }
  }

  // DISPOSE THE AD
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
// INTERESTIAL AD

// NATIVE AD
class NativeExample extends StatefulWidget {
  final TemplateType templateType;
  final String adUnitId;

  const NativeExample(
      {super.key, required this.templateType, required this.adUnitId});

  @override
  NativeExampleState createState() => NativeExampleState();
}

class NativeExampleState extends State<NativeExample>
    with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _nativeAdIsLoaded = false;
  // String? _versionString;

  final double _adAspectRatioSmall = (91 / 355);
  final double _adAspectRatioMedium = /*(370 / 355)*/  (0.90);

  double get _adAspectRatio {
    return (widget.templateType == TemplateType.small)
        ? _adAspectRatioSmall
        : _adAspectRatioMedium;
  }

  @override
  bool get wantKeepAlive => true; // Keep the state alive.

  @override
  void initState() {
    super.initState();
    _loadVersionString();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }
  // In your code, the _loadAd() method is called in initState(), and _loadAd() calls _nativeAdStyle(), which uses Theme.of(context). This is what's causing the error.

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: <Widget>[
            SizedBox(
                height: constraints.maxWidth * _adAspectRatio,
                width: constraints.maxWidth),
            if (_nativeAdIsLoaded && _nativeAd != null)
              SizedBox(
                height: constraints.maxWidth * _adAspectRatio,
                width: constraints.maxWidth,
                child: AdWidget(ad: _nativeAd!),
              ),
          ],
        );
      },
    );
  }

  /// Loads a native ad.
  void _loadAd() {
    setState(() {
      _nativeAdIsLoaded = false;
    });

    _nativeAd = NativeAd(
      adUnitId: widget.adUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          // ignore: avoid_print
          print('$NativeAd loaded.');
          setState(() {
            _nativeAdIsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // ignore: avoid_print
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdClicked: (ad) {},
        onAdImpression: (ad) {},
        onAdClosed: (ad) {},
        onAdOpened: (ad) {},
        onAdWillDismissScreen: (ad) {},
        onPaidEvent: (ad, valueMicros, precision, currencyCode) {},
      ),
      request: const AdRequest(),
      nativeTemplateStyle: _nativeAdStyle(
        templateType: widget.templateType,
      ),
    )..load();
  }

  void _loadVersionString() {
    MobileAds.instance.getVersionString().then((value) {
      setState(() {
        value;
      });
    });
  }

  // Get the native ad style.
  NativeTemplateStyle _nativeAdStyle({required TemplateType templateType}) {
    return NativeTemplateStyle(
      templateType: widget.templateType,
      mainBackgroundColor: Theme.of(context).colorScheme.background,
      cornerRadius: 10.0,
      callToActionTextStyle: NativeTemplateTextStyle(
        textColor: Theme.of(context).colorScheme.onSecondary,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        style: NativeTemplateFontStyle.monospace,
        size: 16.0,
      ),
      primaryTextStyle: NativeTemplateTextStyle(
        textColor: Theme.of(context).colorScheme.onBackground,
        backgroundColor: Theme.of(context).colorScheme.background,
        style: NativeTemplateFontStyle.italic,
        size: 16.0,
      ),
      secondaryTextStyle: NativeTemplateTextStyle(
        textColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.primary,
        style: NativeTemplateFontStyle.bold,
        size: 16.0,
      ),
      tertiaryTextStyle: NativeTemplateTextStyle(
        textColor: Theme.of(context).colorScheme.onSurface,
        backgroundColor: Theme.of(context).colorScheme.surface,
        style: NativeTemplateFontStyle.normal,
        size: 16.0,
      ),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}

// NATIVE AD

// ADAPTIVE ANCHORED BANNER

/// This example demonstrates anchored adaptive banner ads.
class AnchoredAdaptiveExample extends StatefulWidget {
  final String adUnitId;

  const AnchoredAdaptiveExample({super.key, required this.adUnitId});

  @override
  State<AnchoredAdaptiveExample> createState() =>
      _AnchoredAdaptiveExampleState();
}

class _AnchoredAdaptiveExampleState extends State<AnchoredAdaptiveExample>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _anchoredAdaptiveAd;
  bool _isLoaded = false;

  @override
  bool get wantKeepAlive => true; // Keep the state alive.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAd();
  }

  Future<void> _loadAd() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            MediaQuery.of(context).size.width.truncate());

    if (size == null) {
      debugPrint('Unable to get height of anchored banner.');
      return;
    }

    _anchoredAdaptiveAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('$ad loaded: ${ad.responseInfo}');
          setState(() {
            // When the ad is loaded, get the ad size and use it to set
            // the height of the ad container.
            _anchoredAdaptiveAd = ad as BannerAd;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Anchored adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    return _anchoredAdaptiveAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_anchoredAdaptiveAd != null && _isLoaded) {
      return Container(
        color: Colors.grey.shade800,
        width: _anchoredAdaptiveAd!.size.width.toDouble(),
        height: _anchoredAdaptiveAd!.size.height.toDouble(),
        child: AdWidget(ad: _anchoredAdaptiveAd!),
      );
    } else {
      return const SizedBox();
    }
  }

  @override
  void dispose() {
    _anchoredAdaptiveAd?.dispose();
    super.dispose();
  }
}

// ADAPTIVE  ANCHORED BANNER

//ADAPTIVE  INLINE BANNER
class InlineAdaptiveExample extends StatefulWidget {
  final String adUnitId;

  const InlineAdaptiveExample({super.key, required this.adUnitId});

  @override
  State<InlineAdaptiveExample> createState() => _InlineAdaptiveExampleState();
}

class _InlineAdaptiveExampleState extends State<InlineAdaptiveExample>
    with AutomaticKeepAliveClientMixin {
  static const _insets = 16.0;
  BannerAd? _inlineAdaptiveAd;
  bool _isLoaded = false;
  AdSize? _adSize;
  late Orientation _currentOrientation;

  double get _adWidth => MediaQuery.of(context).size.width - (2 * _insets);

  @override
  bool get wantKeepAlive => true; // Keep the state alive.

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentOrientation = MediaQuery.of(context).orientation;
    _loadAd();
  }

  void _loadAd() async {
    await _inlineAdaptiveAd?.dispose();
    setState(() {
      _inlineAdaptiveAd = null;
      _isLoaded = false;
    });

    // Get an inline adaptive size for the current orientation.
    AdSize size = AdSize.getCurrentOrientationInlineAdaptiveBannerAdSize(
        _adWidth.truncate());

    _inlineAdaptiveAd = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) async {
          debugPrint('Inline adaptive banner loaded: ${ad.responseInfo}');

          // After the ad is loaded, get the platform ad size and use it to
          // update the height of the container. This is necessary because the
          // height can change after the ad is loaded.
          BannerAd bannerAd = (ad as BannerAd);
          final AdSize? size = await bannerAd.getPlatformAdSize();
          if (size == null) {
            debugPrint(
                'Error: getPlatformAdSize() returned null for $bannerAd');
            return;
          }

          setState(() {
            _inlineAdaptiveAd = bannerAd;
            _isLoaded = true;
            _adSize = size;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Inline adaptive banner failedToLoad: $error');
          ad.dispose();
        },
      ),
    );
    await _inlineAdaptiveAd!.load();
  }

  /// Gets a widget containing the ad, if one is loaded.
  ///
  /// Returns an empty container if no ad is loaded, or the orientation
  /// has changed. Also loads a new ad if the orientation changes.
  Widget _getAdWidget() {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (_currentOrientation == orientation &&
            _inlineAdaptiveAd != null &&
            _isLoaded &&
            _adSize != null) {
          return Align(
              child: SizedBox(
            width: _adWidth,
            height: _adSize!.height.toDouble(),
            child: AdWidget(
              ad: _inlineAdaptiveAd!,
            ),
          ));
        }
        // Reload the ad if the orientation changes.
        if (_currentOrientation != orientation) {
          _currentOrientation = orientation;
          _loadAd();
        }
        return Container();
      },
    );
  }

// SHOWCASE: InlineAdaptiveExample
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _insets),
      child: _getAdWidget(),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _inlineAdaptiveAd?.dispose();
  }
}
// ADAPTIVE  INLINE BANNER
/* Real Ads */