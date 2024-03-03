import 'dart:io';

class AdUnits {
  static String get bannerForUpdates {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9828119232134269/4904867341';
    } else if (Platform.isIOS) {
      // return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
      return 'ca-app-pub-9828119232134269/4904867341';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeMediumForWOTD {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9828119232134269/9965622338';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9828119232134269/9965622338';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeSmallForPackets {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9828119232134269/5835392360';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9828119232134269/5835392360';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get nativeMediumForPackets {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9828119232134269/1896147352';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9828119232134269/1896147352';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialSwitchTabAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9828119232134269/3411822271';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9828119232134269/3411822271';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialCopyPacketAd {
    if (Platform.isAndroid) {
      return 'ca-app-pub-9828119232134269/5574132942';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-9828119232134269/5574132942';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
