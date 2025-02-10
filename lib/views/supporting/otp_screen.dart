import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/widgets/custom_rich_text.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:pinput/pinput.dart';

import '../../core/utils/utils.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String? phoneNumber;

  OTPScreen({super.key, required this.verificationId, this.phoneNumber});

  static const String id = "OTP_Screen";

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _pinField = TextFieldController();

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(kDefaultRounding),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onBackground),
        centerTitle: true,
        title: const Text(
          "Phone Verification",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Lottie.asset("assets/animations/Phone_OTP.json"),
            ),
            CustomRichText(
                beforeText: "OTP sent on ",
                midBoldText: widget.phoneNumber ?? "NULL",
                afterText: "\n You must verify your phone number"),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Pinput(
                defaultPinTheme: defaultPinTheme,
                controller: _pinField.controller,
                length: 6,
                showCursor: true,
              ),
            ),
            // const SizedBox(
            //   height: 20,
            // ),
            Spacer(),
            SafeArea(
              bottom: true,
              child: CustomPrimaryButton(
                isBold: false,
                  onPressed: () async {
                    try {
                      PhoneAuthCredential credential =
                          await PhoneAuthProvider.credential(
                              verificationId: widget.verificationId,
                              smsCode: _pinField.controller.text.toString());
                      if (credential.smsCode == _pinField.controller.text) {
                        Navigator.pop(context, true);
                      } else {
                        Navigator.pop(context, false);
                      }
                    } catch (e) {
                      Navigator.pop(context, false);
                      Utils.showAlertPopup(
                          context, "Something went wrong", e.toString());
                    }
                  },
                  label: "Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
