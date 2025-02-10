import 'dart:async';
import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/views/directive_home_screen.dart';
import 'package:backcaps_logistics/views/supporting/splash_screen.dart';
import 'package:backcaps_logistics/widgets/custom_rich_text.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../core/utils/utils.dart';
import '../../widgets/static_widgets.dart';
import '../login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  //Adjust timer here
  int countDownDuration = 60;

  bool isEmailVerified = false; // email verification status
  bool isResendButtonActive = false;
  late UserControllerProvider userAuthentication;

  //Timer properties
  Timer? timer;
  Timer? countDownTimer;
  int _currentTickerValue = 0;
  String role = "";

  @override
  void initState() {
    super.initState();
    userAuthentication = UserControllerProvider();
    //Check if current user email is verified or not
    setState(() => isEmailVerified = userAuthentication.isEmailVerified());
    identifyRole();
    //When email verification screen is initialized a timer will start
    //and email verification code will be sent to the email provided during signup
    toggleCountDownTimer();
    // //If email is not verified a verification email will be sent
    if (!isEmailVerified) {
      userAuthentication.sendVerificationEmail();
      startTimer();
    }
  }

  void toggleCountDownTimer() {
    _currentTickerValue = countDownDuration;
    countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentTickerValue > 0) {
        setState(() {
          _currentTickerValue--;
        });
      } else {
        setState(() {
          countDownTimer!.cancel();
          isResendButtonActive = true;
        });
      }
    });
  }

  @override
  void dispose() {
    if (countDownTimer != null) {
      countDownTimer!.cancel();
    }
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  void checkEmailVerification() async {
    try {
      setState(() => isEmailVerified = userAuthentication.isEmailVerified());
      print("Email verification state: $isEmailVerified");
      if (!isEmailVerified) {
        startTimer();
      } else {
        countDownTimer!.cancel();
        timer!.cancel();
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Something wrong in email verification process")));
    }
  }

  void startTimer() {
    if (timer == null || !timer!.isActive) {
      //This method checks every 3 seconds for email verification
      timer = Timer.periodic(const Duration(seconds: 3), (timer) {
        checkEmailVerification();
      });
    }
  }

  Future<void> identifyRole() async {
    if (await userAuthentication.getRole()) {
      setState(() {});
    } else {
      Utils.showAlertPopup(
          context, "No Data Found", "Something is wrong with the database");
      userAuthentication.signOutUser();
    }
  }

  void signOut() {
    userAuthentication.signOutUser();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? (userAuthentication.currentUserRole == null
            ? const Center(child: SplashScreen())
            : HomeScreen(role: userAuthentication.currentUserRole.toString()))
        : Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: signOut,
              ),
              centerTitle: true,
              iconTheme: IconThemeData(
                  color: Theme.of(context).colorScheme.onBackground),
              title: Text(
                "Email Verification",
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Lottie.asset(
                        "assets/animations/Email_Verification.json"),
                  ),
                  CustomRichText(
                      beforeText: "An email has been sent to \n",
                      midBoldText: "${userAuthentication.getEmail()}",
                      afterText:
                          "\n You need to verify your email\n  before proceeding further."),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomPrimaryButton(
                    isBold: false,
                      onPressed: isResendButtonActive
                          ? () {
                              setState(() {
                                isResendButtonActive = false;
                                toggleCountDownTimer();
                              });
                            }
                          : null,
                      label: "Resend Verification Link"),
                  !isResendButtonActive
                      ? const RadialGradientDivider()
                      : Container(),
                  Text(isResendButtonActive
                      ? ""
                      : "Resend in: ${_currentTickerValue.toString().padLeft(2, '0')}s"),
                ],
              ),
            ),
          );
  }
}
