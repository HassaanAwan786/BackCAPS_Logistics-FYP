import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:flutter/material.dart';

class CustomPrimaryButton extends StatelessWidget {
  final String label;
  final bool isBold;
  final Function()? onPressed;

  const CustomPrimaryButton(
      {super.key, required this.onPressed, required this.label,required this.isBold});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
      elevation: 0.0,
      onPressed: onPressed,
      height: 60,
      minWidth: 200,
      color: Theme.of(context).colorScheme.primary,
      // height: 50,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultRounding)),

      child: Text(
        label,
        style: TextStyle(
          fontWeight: isBold ? poppins_bold.fontWeight: poppins.fontWeight,
          fontFamily: poppins_bold.fontFamily,
          color: onPressed != null
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
