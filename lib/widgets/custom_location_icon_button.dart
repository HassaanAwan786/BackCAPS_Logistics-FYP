import 'package:flutter/material.dart';

import '../core/constants/constants.dart';

class CustomLocationIconButton extends StatelessWidget {
  final double borderRadius;
  final double fontSize;
  const CustomLocationIconButton({
    super.key,
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
        onPressed: () {},
        icon: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Column(
            children: [
              const Icon(Icons.location_on_outlined),
              Text("Map", style: poppins.copyWith(fontSize: fontSize))
            ],
          ),
        ));
  }
}
