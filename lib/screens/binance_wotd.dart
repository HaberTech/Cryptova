import 'package:flutter/material.dart';
import 'package:cryptova/screens/share_widget.dart';
import 'package:cryptova/backend/screens/binace_wotd.dart';

import 'package:cryptova/backend/adunits.dart';
import 'package:cryptova/backend/ads.dart' show NativeExample, TemplateType;

class BinanceWODLSection extends StatefulWidget {
  const BinanceWODLSection({super.key});
  @override
  State<BinanceWODLSection> createState() => _BinanceWODLSectionState();
}

class _BinanceWODLSectionState extends State<BinanceWODLSection>
    with AutomaticKeepAliveClientMixin {
  late List<List<String>> wordsArray;

  @override
  bool get wantKeepAlive => true; // This will keep the state of the widget

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // You need to call super.build in your build method when using AutomaticKeepAliveClientMixin
    return FutureBuilder(
      future: getWords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          debugPrint('Error: ${snapshot.error}');
          return const Text('WOTD Error: Try updating or reopening the app');
        } else {
          wordsArray = snapshot.data!;
          debugPrint('################# WordsArray: $wordsArray');
          return _wordsList();
        }
      },
      //  _wordsList(),
    );
  }

  ListView _wordsList() {
    return ListView.separated(
      addAutomaticKeepAlives: true,
      itemCount: wordsArray.length + 1, // Add 1 for the share card
      separatorBuilder: (context, index) => index != 0
          ? Card(
              child: NativeExample(
                  adUnitId: AdUnits.nativeMediumForWOTD,
                  templateType: TemplateType.medium),
            ) // Insert ad but not at the top
          : const SizedBox(),
      itemBuilder: (context, outerIndex) {
        if (outerIndex == 0) return const Card(child: ShareToFriendsCard());
        outerIndex =
            outerIndex - 1; // Adjust index to account for the share card
        return Column(
          children: <Widget>[
            ListTile(
              title: Text(
                'Binance ${wordsArray[outerIndex][0].length} Letter Word Of The Day',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              addAutomaticKeepAlives: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: wordsArray[outerIndex].length,
              itemBuilder: (context, innerIndex) {
                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.star,
                      color: Colors.lightBlue,
                    ),
                    title: Text(wordsArray[outerIndex][innerIndex]),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
