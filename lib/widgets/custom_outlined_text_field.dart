import 'package:flutter/material.dart';

import '../core/constants/constants.dart';
import '../core/utils/text_handler.dart';

TextFormField CustomOutlinedTextField(
  context, {
  bool readOnly = false,
  bool isNumber = false,
  Widget? icon,
  TextInputType type = TextInputType.name,
  String label = "Placeholder",
  String? placeholder,
  IconData? suffixIcon,
  Color? suffixIconColor,
  Function()? onSuffixPressed,
  TextFieldController? textFieldController,
  Function(String value)? onChanged,
  String? Function(String? value)? validator,
}) {
  return TextFormField(
    readOnly: readOnly,
    controller: textFieldController!.controller,
    keyboardType: type,
    style: poppins,
    onChanged: onChanged,
    decoration: InputDecoration(
      hintText: placeholder,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: false,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
        color: Theme.of(context).colorScheme.onBackground,
      )),
      prefixIcon: icon != null
          ? icon
          : isNumber
              ? Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    '+92 |',
                    style: poppins,
                  ))
              : null,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onBackground,
        fontStyle: poppins.fontStyle,
      ),
      label: Text(label),
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(suffixIcon, color: suffixIconColor),
              onPressed: onSuffixPressed,
            )
          : null,
    ),
    validator: validator,
  );
}


String? Function(String?)? validatorFunction(String? message) {
  return (String? value) {
    if (value == null || value.isEmpty) return message;
    return null;
  };
}
