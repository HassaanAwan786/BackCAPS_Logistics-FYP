import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/structure/Location.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:backcaps_logistics/widgets/custom_text_field.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/constants.dart';
import '../core/controllers/user_controller.dart';
import '../core/utils/utils.dart';
import 'supporting/redirect_user.dart';
import '../structure/Customer.dart';
import '../structure/enums/Role.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const String id = "Signup_Screen";

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailField = TextFieldController();
  final _passwordField = TextFieldController();
  final _username = TextFieldController();
  final _name = TextFieldController();
  bool isPasswordVisible = true;
  late UserControllerProvider provider;
  bool isLoading = false;

 @override
  void initState() {
    super.initState();
    provider = UserControllerProvider();
  }
  Future<bool> createAccount() async {
    try {
      setState(() => isLoading = true);
      provider.currentUserRole = Role.Customer;
      await provider.signupUser(
          email: _emailField.controller.text,
          password: _passwordField.controller.text);
      final newUser = Customer(
        imageUrl: "NULL",
        name: _name.controller.text,
        username: _username.controller.text,
        email: _emailField.controller.text,
        phoneNumber: "NULL",
        phoneVerified: false,
        registrationTime: DateTime.now().toString(),
        cnic: "NULL",
        rating: 0.0,
        location: Location(latitude: 0.0, longitude: 0.0, address: "NULL"),
        role: provider.currentUserRole.toString(),
        customerID: const Uuid().v1(),
        numberOfOrders: 0,
      );
      provider.createUser(newUser);
      return true;
    } on FirebaseAuthException catch (e) {
      Utils.showAlertPopup(
          context, "Something went wrong", e.message.toString());
      return false;
    } catch (e) {
      setState(() {
        Utils.showAlertPopup(context, "Something went wrong", e.toString());
      });
      return false;
    }finally{
      setState(() => isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          logisticLogo(height: 150, context: context),
                          buildHeadingText("Signup"),
                          const Spacer(),
                          _buildSignupFields(),
                          CustomPrimaryButton(
                            isBold: false,
                            onPressed: () async {
                              //Check if any field is not empty
                              if (checkFields()) {
                                if (await checkSameUsername()) {
                                  if (await createAccount()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Email verification required")));
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => RedirectUser()));
                                  }
                                }
                              }
                            },
                            label: "Sign up",
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account?"),
                              TextButton(
                                child: const Text("Login"),
                                onPressed: () {
                                  if (provider.auth.currentUser != null) {
                                    provider.signOutUser();
                                  }
                                  Navigator.pop(context);
                                },
                              )
                            ],
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          loadingBackgroundBlur(isLoading),
          loadingIndicator(context, isLoading),
        ],
      ),
    );
  }

  Column _buildSignupFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomTextField(
          icon: Icons.person,
          type: TextInputType.name,
          textFieldController: _name,
          label: "Full Name",
        ),
        CustomTextField(
          icon: Icons.badge,
          type: TextInputType.name,
          textFieldController: _username,
          label: "Unique ID/ Username",
        ),
        CustomTextField(
          icon: Icons.email,
          type: TextInputType.emailAddress,
          textFieldController: _emailField,
          label: "Email Address",
        ),
        TextField(
          obscureText: isPasswordVisible,
          controller: _passwordField.controller,
          decoration: kInputFieldDecoration.copyWith(
            hintText: "Password",
            errorText: _passwordField.errorText,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
          ),
          onChanged: (value) => setState(() {
            // _confirmPasswordField.errorText = "";
            _passwordField.errorText = "";
          }),
        ),
      ],
    );
  }

  bool checkFields() {
    bool fieldError = false;
    List<_TextFieldErrorHandling> inputFields = [
      _TextFieldErrorHandling(_emailField, "Email is Required"),
      _TextFieldErrorHandling(_username, "Username is Required"),
      _TextFieldErrorHandling(_name, "Full Name is Required"),
      _TextFieldErrorHandling(_passwordField, "Password is Required"),
    ];

    for (var textField in inputFields) {
      setState(() => textField.controller.errorText = "");
      if (textField.controller.controller.text.isEmpty) {
        setState(() => textField.controller.errorText = textField.error);
        fieldError = true;
      }
    }

    if(checkSpecialCharacters(_username, false)){
      setState(() => _username.errorText = "Special characters/numbers are not allowed");
      if(!fieldError){
        fieldError = true;
      }
    }
    if(checkSpecialCharacters(_name, true)){
      setState(() => _name.errorText = "Special characters/numbers are not allowed");
      if(!fieldError){
        fieldError = true;
      }
    }
    //in case user enter email and username in capital letters
    convertToLowerCase();
    return !fieldError;
  }

  bool checkSpecialCharacters(TextFieldController field, bool checkNumbers) {
    final specialCharacters = [
      '!',
      '@',
      '#',
      '\$',
      '%',
      '^',
      '&',
      '*',
      '(',
      ')',
      '-',
      '+',
      '=',
      ';',
      ':',
      '\'',
      '\"',
      '\\',
      '|',
      '{',
      '}',
      '[',
      ']',
      ',',
      '.',
      '/',
      '?',
      '<',
      '>',
      '`',
      '§',
      '±',
      '~'
    ];
    for (int i = 0; i < field.controller.text.length; i++) {
      if(checkNumbers){
        for(int k = 0; k < 9; k++){
          if(field.controller.text[i] == '$k'){
            return true;
          }
        }
      }
      for(int j = 0; j < specialCharacters.length; j++){
        if (specialCharacters[j] == field.controller.text[i]) {
          return true;
        }
      }
    }
    return false;
  }

  void convertToLowerCase() {
    _emailField.controller.text = _emailField.controller.text.toLowerCase();
    _username.controller.text = _username.controller.text.toLowerCase();
  }

  Future<bool> checkSameUsername() async {
    setState(() => isLoading = true);
    if (!await provider.checkSameUsername(_username.controller.text)) {
      setState(() {
        _username.errorText = "Username already exists";
      });
      setState(() => isLoading = false);
      return false;
    } else {
      setState(() => isLoading = false);
      return true;
    }
  }
}

class _TextFieldErrorHandling {
  late TextFieldController controller;
  late String error;

  _TextFieldErrorHandling(this.controller, this.error);
}
