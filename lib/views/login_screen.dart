import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/views/signup_screen.dart';
import 'package:backcaps_logistics/views/supporting/forget_password_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/constants.dart';
import '../core/utils/text_handler.dart';
import '../core/utils/utils.dart';
import '../widgets/custom_primary_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/static_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = "Login_Screen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailField = TextFieldController();
  final _passwordField = TextFieldController();
  final UserControllerProvider userAuth = UserControllerProvider();
  bool _isPasswordVisible = true;
  bool isLoading = false;

  Future<bool> signInWithEmailAndPassword() async {
    try {
      setState(()=> isLoading = true);
      //Check if field contains '@' symbol that means it is an email
      //else it is username
      if(_emailField.controller.text.contains("@")){
        await userAuth.signInWithEmail(_emailField.controller.text, _passwordField.controller.text);
      }
      else {
        if(!await userAuth.signInWithUsername(_emailField.controller.text, _passwordField.controller.text)){
          throw "The username & password must be valid.";
        }
      }
      return true;
    } on FirebaseAuthException catch (exception) {
      setState(() {
        _emailField.errorText = "Invalid Username or Email";
        _passwordField.errorText = "Invalid Password";
        Utils.showAlertPopup(context, "Something went wrong", exception.code.toString());
      });
      return false;
    } catch(e){
      setState(() {
        _emailField.errorText = "Invalid Username or Email";
        _passwordField.errorText = "Invalid Password";
        Utils.showAlertPopup(context, "Something went wrong", e.toString());
      });
      return false;
    }finally{
      setState(()=> isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          logisticLogo(context: context),
                          buildHeadingText("Login"),
                          const Spacer(),
                          _buildLoginFields(),
                          //Login button
                          CustomPrimaryButton(
                            isBold: false,
                            label: "Log in",
                            onPressed: () {
                              signInWithEmailAndPassword();
                            },
                          ),
                          //Signup button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                child: const Text("Signup"),
                                onPressed: () {
                                  Navigator.pushNamed(context, SignupScreen.id);
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

  Column _buildLoginFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomTextField(
          icon: Icons.person,
            type: TextInputType.emailAddress,
            label: "Username or Email",
            textFieldController: _emailField
        ),
        //Password field
        TextField(
          controller: _passwordField.controller,
          obscureText: _isPasswordVisible,
          decoration: kInputFieldDecoration.copyWith(
            prefixIcon: const Icon(Icons.lock),
            hintText: "Password",
            errorText: _passwordField.errorText,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(
            () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()));
            },
          ),
          child: const Text("Forget Password?"),
        ),
      ],
    );
  }

}
