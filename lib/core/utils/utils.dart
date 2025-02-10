import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'dart:io' show Platform;

class Utils {
  static showLoadingIndicator(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
            borderRadius: BorderRadius.circular(kDefaultRounding),
          ),
          padding: const EdgeInsets.all(40),
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  static showAlertPopup(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                child: const Text("Okay"),
              ),
            )
          ],
        );
      },
    );
  }

  static Future<void> showConfirmationDialogue(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Function() onConfirm,
    Function()? onCancel,
    String cancelText = "Cancel",
  }) async {
    Widget cancelButton() => TextButton(
          onPressed: (){
            if(onCancel!=null) {
              onCancel;
            } else {
              Navigator.of(context).pop(false);
            }
          },
          child: Text(cancelText),
        );
    Widget confirmButton() => TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm();
          },
          child: Text(confirmText),
        );
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [cancelButton(), confirmButton()],
    );
    if (Platform.isIOS) {
      showCupertinoModalPopup(context: context, builder: (_) => alert);
    } else {
      showDialog(context: context, builder: (_) => alert);
    }
  }
}
