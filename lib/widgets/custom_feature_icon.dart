import 'package:flutter/material.dart';

class CustomFeatureIcon extends StatelessWidget {
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;

  const CustomFeatureIcon({
    super.key,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: backgroundColor!=null? backgroundColor : Colors.white,
      child: Icon(icon, color: iconColor!=null? iconColor : Colors.black),
    );
  }
}
