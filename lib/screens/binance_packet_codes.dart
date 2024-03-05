import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cryptova/backend/ads.dart'
    show InterstitialAdExample, NativeExample, TemplateType;
import 'package:cryptova/backend/adunits.dart';
import 'package:cryptova/screens/share_widget.dart';
import 'package:cryptova/backend/screens/binance_packet_codes.dart';

class BinananceCryptoBoxesSection extends StatefulWidget {
  const BinananceCryptoBoxesSection({super.key});

  @override
  State<BinananceCryptoBoxesSection> createState() =>
      _BinananceCryptoBoxesSectionState();
}

class _BinananceCryptoBoxesSectionState
    extends State<BinananceCryptoBoxesSection>
    with AutomaticKeepAliveClientMixin {
  bool isLoading = false;
  bool hasMoreCodes = true;
  int adIndex = 0; // Initialize ad index
  final int adInterval = 5; // Insert an ad every 5 items

  final List<dynamic> _wordsArray = [];
  final List<NativeExample> _nativeAds = [];

  late SharedPreferences sharedPreferences;
  final ScrollController _scrollController = ScrollController();
  final InterstitialAdExample packetsInterstitialAd =
      InterstitialAdExample(adUnitId: AdUnits.interstitialCopyPacketAd);

  @override
  bool get wantKeepAlive => true; // Keep the state alive

  Future<void> _loadCodes() async {
    setState(() {
      isLoading = true;
    });

    try {
      int lastCodeId = _wordsArray.isNotEmpty ? _wordsArray.last['Id'] : 0;
      List<dynamic> moreWords = await getCodes(lastCodeId);

      // Check if there are more codes
      hasMoreCodes = moreWords.isNotEmpty;

      setState(() {
        _wordsArray.addAll(moreWords);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        // error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // You need to call super.build in your build method when using AutomaticKeepAliveClientMixin
    return _wordsArray.isNotEmpty
        ? _wordsList()
        : FutureBuilder(
            future: _loadCodes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                debugPrint('Error: ${snapshot.error}');
                return const Text(
                    'PackesSection Error: Try updating or repening the app');
              } else {
                return _wordsList();
              }
            },
          );
  }

  ListView _wordsList() {
    final int totalItems = _wordsArray.length +
        (_wordsArray.length / adInterval).floor(); // Total items including ads

    return ListView.builder(
      controller: _scrollController..addListener(_scrollListener),
      key: const PageStorageKey('packets_list'),
      cacheExtent: totalItems * 25.0,
      // Absent = I/flutter ( 6328): TotalIndex: 120 AppIndex: 9, adIndex: 1, isAdIndex: false
      // 25.0 = I/flutter ( 6328): TotalIndex: 120 AppIndex: 35, adIndex: 5, isAdIndex: true
      // 50.0 = I/flutter ( 6328): TotalIndex: 120 AppIndex: 59, adIndex: 9, isAdIndex: true
      // 100.0 = I/flutter ( 6328): TotalIndex: 120 AppIndex: 117, adIndex: 19, isAdIndex: false
      addAutomaticKeepAlives: true,
      itemCount: totalItems + 1, // Add 1 for the share card
      itemBuilder: (context, index) {
        if (index == 0) return const Card(child: ShareToFriendsCard());
        if (index == totalItems && isLoading) {
          // If it's the last item and more posts are being loaded
          return const Center(child: CircularProgressIndicator());
        } else if (index == totalItems && !hasMoreCodes) {
          // If it's the last item and there are no more posts
          return const Center(child: Text('No more codes'));
        }

        index = index - 1; // Adjust index to account for the share card
        bool isAdIndex = (index + 1) % (adInterval + 1) ==
            0; // Check if this index is for an ad

        // if(_nativeAds.length >= adIndex)
        return isAdIndex ? _buildAd() : _buildWord(index);
      },
    );
  }

  void _scrollListener() {
    if (!isLoading &&
        hasMoreCodes &&
        _scrollController.position.extentAfter < 500) {
      // If the scroll position is less than 500px from the bottom
      _loadCodes(); // Load more posts
    }
  }

  Widget _buildAd() {
    TemplateType templateType = (adIndex % 2 == 0)
        ? TemplateType.small
        : TemplateType.medium; // Alternate between small and medium ads
    String adUnitId = (templateType == TemplateType.small)
        ? AdUnits.nativeSmallForPackets
        : AdUnits.nativeMediumForPackets;

    if (_nativeAds.length <= adIndex) {
      // If there's no ad for this index yet, create one
      NativeExample nativeAd = NativeExample(
        templateType: templateType,
        adUnitId: adUnitId,
      );
      _nativeAds.add(nativeAd);
    }

    adIndex = adIndex + 1; // Increment ad index by 1
    return Card(
      child: _nativeAds[adIndex - 1], // Use the ad for this old index
    );
  }

  Widget _buildWord(int index) {
    int wordIndex = index - (index / (adInterval + 1)).floor();
    String code = _wordsArray[wordIndex]['Code'].toString();
    //Treat the string to be UTC and parse it to DateTime
    DateTime date = DateTime.parse(_wordsArray[wordIndex]['DateAdded'] + 'Z');
    return CardForCode(
      code: code,
      date: date,
      interestialAd: packetsInterstitialAd,
      sharedPreferences: sharedPreferences,
    );
  }

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) => sharedPreferences = value);
    super.initState();
  }

  @override
  void dispose() {
    packetsInterstitialAd.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class CardForCode extends StatelessWidget {
  const CardForCode({
    super.key,
    required this.code,
    required this.date,
    required this.interestialAd,
    required this.sharedPreferences,
  });

  final String code;
  final DateTime date;
  final InterstitialAdExample interestialAd;
  final SharedPreferences sharedPreferences;
  final String sharedPrefKey = 'countsSinceLastAdShow';

  Future<void> _copyCodeToClipboard(
    BuildContext context,
    String code,
  ) async {
    // Get the counter value from SharedPreferences, defaulting to 0 if it's not set
    final countsSinceLastShow = sharedPreferences.getInt(sharedPrefKey) ?? 0;

    if (countsSinceLastShow >= 3 || interestialAd.countsSinceLastShow >= 3) {
      interestialAd.showAd(); // Show the ad and reset the internal counter
      // Resets the counter to 0
      await sharedPreferences.setInt(sharedPrefKey, 0);
    } else {
      // Increase the counters
      interestialAd.addToCountsSinceLastShow();
      await sharedPreferences.setInt(sharedPrefKey, countsSinceLastShow + 1);
    }

    // Log the event
    FirebaseAnalytics.instance
        .logEvent(name: 'copy_packet_code', parameters: {'Code': code});

    // Copy the code to the clipboard
    return Clipboard.setData(ClipboardData(text: code)).then(
      (value) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      ),
    );
  }

  String formatDateTime(DateTime date) {
    final now = DateTime.now().toUtc(); // Get the current date and time in UTC
    final difference =
        now.difference(date); // Get the difference between the two as UTC
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday at ${DateFormat('hh:mm a').format(date)}';
    } else {
      return DateFormat('yyyy-MM-dd hh:mm a').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(
            code,
            textAlign: TextAlign.center,
          ),
          subtitle: Text(
            formatDateTime(date),
            textAlign: TextAlign.center,
          ), // Align the text to the center), // Use the function here
          trailing: Semantics(
            label: 'Copy code to clipboard',
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () async => await _copyCodeToClipboard(context, code),
            ),
          )),
    );
  }
}
