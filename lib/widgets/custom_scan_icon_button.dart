import 'package:flutter/material.dart';

import '../core/constants/constants.dart';

class CustomScanIconButton extends StatelessWidget {
  final Function() onPressed;
  final double borderRadius;
  final double fontSize;
  const CustomScanIconButton({
    super.key,
    required this.onPressed,
    this.borderRadius = 7.0,
    this.fontSize = 14.0
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
        style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ))),
        onPressed: onPressed,
        icon: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: [
              const Icon(Icons.camera_alt_outlined),
              Text("Scan", style: poppins.copyWith(fontSize: fontSize))
            ],
          ),
        ));
  }
}
