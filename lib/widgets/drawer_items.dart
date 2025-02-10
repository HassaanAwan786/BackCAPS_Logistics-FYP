import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  final TextStyle textStyle;
  DrawerItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    TextStyle? textStyle,
  }) : textStyle = textStyle ?? poppins;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon),
        title: Text(text, style: textStyle),
      ),
    );
  }
}
