import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareToFriendsCard extends StatelessWidget {
  const ShareToFriendsCard({super.key});

  Future<void> _shareApp(BuildContext context) async {
    // For Ipad
    final box = context.findRenderObject() as RenderBox?;

    final ShareResult result = await Share.shareWithResult(
      "Check out Crypto Rewards, Get acess to free crypto rewards and gift boxes!\nDownload the app now: https://apps.habertech.info/2024/02/cryptorewards.html",
      subject: 'Crypto Rewards',
      sharePositionOrigin: box!.localToGlobal(Offset.zero) &
          box.size, // position of the share button for ipad
    );

    final String status = (result.status == ShareResultStatus.success)
        ? 'Successful'
        : 'Unsuccessful';
    // Log the  Share Event
    FirebaseAnalytics.instance.logShare(
        itemId: 'app',
        contentType: status,
        method: Platform.isAndroid ? 'Android' : 'IOS');
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.share),
      trailing: const Icon(
        Icons.chevron_right,
        size: 40,
      ),
      title: const Text('Share App with Friends'),
      subtitle: const Text('Enjoying the app? Share it with your friends!'),
      onTap: () {
        // Share to friends
        _shareApp(context);
      },
    );
  }
}
