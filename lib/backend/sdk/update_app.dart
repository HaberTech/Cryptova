import 'package:flutter/material.dart';
import 'package:cryptova/backend/sdk/habersdk.dart' show HaberApp;
import 'package:url_launcher/url_launcher.dart' as url_launcher;

Future<void> checkAndShowUpdateDialog({
  required HaberApp app,
  required BuildContext context,
  Function? onAllowMinorUpdate,
  Function? onAllowMajorUpdate,
  Function? onDismissMinorUpdate,
  Function? onDismissMajorUpdate,
}) {
  if (app.isUpdated) {
    // Future.delayed(
    //     const Duration(seconds: 3), () => app.isUpdated ? onUpdateDismissed() : null);
  } else {
    // Show user update dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false, // Prevent dialog from closing on back press
          child: AlertDialog(
            title: Text(
                app.updateIsMajor ? 'Major Update Needed' : 'Update Available'),
            content: Text(app.updateIsMajor
                ? app.appConfig[app.platform]['MajorUpdateNotice']
                : app.appConfig[app.platform]['MinorUpdateNotice']),
            actions: [
              TextButton(
                onPressed: () {
                  app.updateIsMajor
                      ? onDismissMajorUpdate ??
                          () // Null will make user stuck there
                      : Navigator.pop(context);
                  onDismissMinorUpdate?.call();
                },
                child: Text(app.updateIsMajor ? 'Exit' : 'Later'),
              ),
              TextButton(
                  onPressed: () {
                    app.updateIsMajor
                        ? onAllowMajorUpdate?.call()
                        : onAllowMinorUpdate?.call();
                    // Open app store
                    url_launcher.launchUrl(Uri.parse(
                        app.appConfig[app.platform]['MinorUpdateUrl']));
                    Navigator.pop(context);
                  },
                  child: const Text('Update')),
            ],
          ),
        );
      },
    );
  }
  return Future.value();
}
