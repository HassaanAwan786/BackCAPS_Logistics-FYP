import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/views/supporting/email_verification.dart';
import 'package:flutter/material.dart';
import '../login_screen.dart';

class RedirectUser extends StatelessWidget {
  const RedirectUser({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: UserControllerProvider().auth.authStateChanges(),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return const EmailVerificationScreen();
        }
        else{
          return const LoginScreen();
        }
      },
    );
  }
}
