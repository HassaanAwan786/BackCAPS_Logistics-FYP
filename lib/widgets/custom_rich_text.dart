import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:flutter/material.dart';

class CustomRichText extends StatelessWidget {
  final String beforeText;
  final String midBoldText;
  final String afterText;

  const CustomRichText(
      {super.key,
      required this.beforeText,
      required this.midBoldText,
      required this.afterText});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      style: poppins,
      TextSpan(
        text: beforeText,
        children: <TextSpan>[
          TextSpan(
            text: midBoldText,
            style: const TextStyle(
              fontWeight: FontWeight.bold, // Add bold style
            ),
          ),
          TextSpan(text: afterText),
        ],
      ),
      textAlign: TextAlign.center,
      textWidthBasis: TextWidthBasis.longestLine,
    );
  }
}
