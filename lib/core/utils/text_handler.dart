import 'package:flutter/cupertino.dart';

class TextFieldController{
  late String errorText;
  late TextEditingController controller;
  TextFieldController(){
    errorText = "";
    controller = TextEditingController();
  }
}