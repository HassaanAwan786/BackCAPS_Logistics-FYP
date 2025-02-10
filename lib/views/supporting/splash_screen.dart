import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/static_widgets.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logisticLogo(height: 100, context: context),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
              Column(
                children: [
                  Text("Powered by".toUpperCase(),
                      style: const TextStyle(fontFamily: "Futura", fontWeight: FontWeight.w500)),
                  const SizedBox(height:5),
                  const Image(
                    image: AssetImage("assets/images/logos/CUST_logo.png"),
                    height: 43,
                    width: 43,
                  ),
                  Text(
                    "Capital University of Science & \nTechnology",
                    style: GoogleFonts.tinos(),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
