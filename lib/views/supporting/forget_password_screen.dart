import 'dart:async';

import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:backcaps_logistics/widgets/custom_text_field.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../core/utils/utils.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}


class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  UserControllerProvider userAuth = UserControllerProvider();
  final _phoneField = TextFieldController();
  bool isLoading = false;
  Future<bool> sendPasswordResetEmail() async {
    try {
      setState(() => isLoading = true);
      if(await userAuth.sendEmailVerification(_phoneField.controller.text)){
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Email has been sent.")));
      }
      return true;
    } on FirebaseAuthException catch (e) {
      print(e);
      Utils.showAlertPopup(context, "Something went wrong.", "${e.message}");
      return false;
    } finally{
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Forget Password"),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Lottie.asset("assets/animations/Forget_Password.json"),
                  const SizedBox(height: 30),
                  Text("You must enter your email to reset your password.", style: GoogleFonts.poppins(),),
                  const SizedBox(height: 15),
                  CustomTextField(
                    type: TextInputType.emailAddress,
                    icon: Icons.email,
                    label: "Enter email address here",
                    textFieldController: _phoneField,
                    errorExist: false
                  ),
                  const SizedBox(height: 5),
                  RadialGradientDivider(),
                  const SizedBox(height: 5),
                  CustomPrimaryButton(onPressed: () async {
                    if(await sendPasswordResetEmail()){
                      Navigator.pop(context);
                    }
                  }, label: "Send Verification Link",
                   isBold: false,),
                ],
              ),
            ),
          ),
        ),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading)
      ],
    );
  }
}

