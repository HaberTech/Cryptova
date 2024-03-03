import 'package:cryptova/backend/ads.dart';
import 'package:cryptova/screens/screens.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cryptova/backend/sdk/appconfig.dart';
import 'package:cryptova/backend/sdk/habersdk.dart'
    show HaberApp, checkAndShowUpdateDialog;

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CryptovaApp());
}

class CryptovaApp extends StatelessWidget {
  const CryptovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine brightness of the current theme
    final Brightness brightnessValue =
        MediaQuery.of(context).platformBrightness;
    // Set system navigation bar color
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: brightnessValue == Brightness.dark
          ? Colors.black
          : Colors.white, // Navigation bar color
      systemNavigationBarIconBrightness: brightnessValue == Brightness.dark
          ? Brightness.light
          : Brightness.dark, // Navigation bar icons' color
    ));
    return MaterialApp(
      title: 'Cryptova',
      home: const CryptovaHomePage(),
      themeMode: ThemeMode.system, // Use system theme
      // THEMES
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          brightness: Brightness.light, // Set brightness for light theme
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Use dark brightness
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          brightness: Brightness.dark, // Set brightness for dark theme
        ),
        useMaterial3: true,
      ),
      // THEMES
    );
  }
}

class CryptovaHomePage extends StatefulWidget {
  const CryptovaHomePage({super.key});

  @override
  State<CryptovaHomePage> createState() => _CryptovaHomePageState();
}

class _CryptovaHomePageState extends State<CryptovaHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final InterstitialAdExample interstitialAdExample = InterstitialAdExample(
    adUnitId: AdUnits.interstitialSwitchTabAd,
  );
  final List tabScreenNames = ['BinanceWOTD', 'UpdatesSection', 'CryptoBoxes'];

  @override
  void initState() {
    super.initState();
    _CheckAppUpdate(context: context); // Check for app updates
    _tabController = TabController(initialIndex: 1, length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // Show the ad when a tab is selected
        interstitialAdExample.showAd();
        FirebaseAnalytics.instance.logScreenView(
            screenClass: 'tabview',
            screenName: tabScreenNames[_tabController.index]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 25,
        title: ListTile(
            leading: Image.asset('assets/cryptova_116.png', height: 20, width: 20),
            title: const Text('Cryptova')),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(icon: Icon(Icons.book_rounded), text: 'WOTD'),
            Tab(icon: Icon(Icons.update), text: 'NEWS'),
            Tab(icon: Icon(Icons.card_giftcard_rounded), text: 'BOXES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const <Widget>[
          BinanceWODLSection(),
          CryptovaUpdatesSection(),
          BinananceCryptoBoxesSection(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _CheckAppUpdate {
  final BuildContext context;
  late HaberApp haberAppInstance;
  final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;

  _CheckAppUpdate({required this.context}) {
    haberAppInstance = HaberApp(config: config);
    haberAppInstance.initialise().then((value) => _checkForUpdate());
  }

  Function _logFirebaseUpdateEvent(String name) {
    return () {
      firebaseAnalytics.logEvent(name: name);
    };
  }

  _checkForUpdate() {
    checkAndShowUpdateDialog(
      app: haberAppInstance,
      context: context,
      onAllowMinorUpdate: _logFirebaseUpdateEvent('update_allowed_minor'),
      onAllowMajorUpdate: _logFirebaseUpdateEvent('update_allowed_major'),
      onDismissMinorUpdate: _logFirebaseUpdateEvent('update_dismissed_minor'),
      onDismissMajorUpdate: _logFirebaseUpdateEvent('update_dismissed_major'),
    );
  }
}
