import 'package:flutter/material.dart';
import '../core/constants/constants.dart';
import '../core/utils/text_handler.dart';

TextFormField CustomTextField({
  IconData? icon,
  TextInputType type = TextInputType.name,
  String label = "Placeholder",
  bool errorExist = true,
  TextFieldController? textFieldController,
  Function(String value)? onChanged,
  String? Function(String? value)? validator,
}) {
  return TextFormField(
    controller: textFieldController!.controller,
    keyboardType: type,
    decoration: kInputFieldDecoration.copyWith(
      prefixIcon: icon != null
          ? Icon(icon)
          : Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            '+92 |',
            style: poppins,
          )),
      hintText: label,
      errorText: errorExist? textFieldController.errorText : null,
    ),
    onChanged: onChanged,
    validator: validator,
  );
}