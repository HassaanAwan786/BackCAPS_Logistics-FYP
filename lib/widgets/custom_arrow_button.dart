import 'package:flutter/material.dart';

class CustomArrowButton extends StatelessWidget {
  double size;
  final Function()? onPressed;

  CustomArrowButton({
    super.key,
    this.size = 28,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      child: InkWell(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(36)),
          width: size,
          height: size,
          child: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.black,
            size: 17,
          ),
        ),
      ),
    );
  }
}
