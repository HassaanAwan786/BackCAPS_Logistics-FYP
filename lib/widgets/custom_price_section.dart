import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';

class CustomPriceSection extends StatelessWidget {
  final TextFieldController controller;
  final Function()? onMinusPressed;
  final Function()? onMinusLongPressed;
  final Function()? onPlusPressed;
  final Function()? onPlusLongPressed;

  const CustomPriceSection({
    super.key,
    required this.controller,
    this.onMinusPressed,
    this.onMinusLongPressed,
    this.onPlusPressed,
    this.onPlusLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Ink(
            child: InkWell(
                onTap: onMinusPressed,
                onLongPress: onMinusLongPressed,
                child: Icon(Icons.do_not_disturb_on_rounded,
                    color: Theme.of(context).colorScheme.primary)),
          ),
          const SizedBox(width: 5),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(kDefaultRounding),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Rs", style: poppins_bold.copyWith(fontSize: 20)),
                  const SizedBox(width: 5),
                  CustomVerticalDivider(
                      height: 22.5,
                      width: 2.5,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(width: 7),
                  Text(controller.controller.text,
                      style: poppins_bold.copyWith(fontSize: 20)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          Ink(
            child: InkWell(
              onTap: onPlusPressed,
              onLongPress: onPlusLongPressed,
              child: Icon(Icons.add_circle_rounded,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
