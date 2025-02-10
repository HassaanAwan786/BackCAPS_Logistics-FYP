import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/controllers/user_controller.dart';
import '../../core/utils/utils.dart';
import '../../structure/enums/Role.dart';
import '../../widgets/custom_primary_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/static_widgets.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String? phoneNumber;

  const PhoneVerificationScreen({super.key, this.phoneNumber});

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneField = TextFieldController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null) {
      _phoneField.controller.text = widget.phoneNumber!;
    }
  }

  Future<void> handlePhoneNumberVerification() async {
    try {
      setState(() => isLoading = true);
      bool verified =
          await Provider.of<UserControllerProvider>(context, listen: false)
              .verifyPhoneNumber("+92${_phoneField.controller.text}", context);
      if (verified) {
        print("Congratulation Phone is verified");
        // Update phone number status in Firebase
        Provider.of<UserControllerProvider>(context, listen: false)
            .updatePhone(_phoneField.controller.text);
      } else {
        throw Exception("Invalid code entered");
      }
    } catch (e) {
      Utils.showAlertPopup(context, "Something went wrong", e.toString());
    }finally{
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text("Enter phone number"),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Provider.of<UserControllerProvider>(context, listen: false)
                    .updateRole(Role.Customer);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const RedirectUser()));
              },
            ),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Lottie.asset("assets/animations/Phone_Verification.json"),
                  const SizedBox(height: 30),
                  Text(
                    "You must enter your phone number to continue.",
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    type: TextInputType.phone,
                    label: "Enter phone number here",
                    textFieldController: _phoneField,
                    errorExist: false,
                  ),
                  const SizedBox(height: 5),
                  const RadialGradientDivider(),
                  const SizedBox(height: 5),
                  CustomPrimaryButton(
                      isBold: true,
                      onPressed: () async {
                        if (_phoneField.controller.text.isNotEmpty) {
                          if (_phoneField.controller.text[0] == '0') {
                            _phoneField.controller.text =
                                _phoneField.controller.text.substring(1);
                          }
                          if (_phoneField.controller.text.length != 10) {
                            Utils.showAlertPopup(
                                context,
                                "Oops!! Something went wrong",
                                "Invalid phone number entered.");
                            return;
                          }
                          await handlePhoneNumberVerification();
                        }
                      },
                      label: "Continue"),
                ],
              ),
            ),
          ),
        ),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading),
      ],
    );
  }
}
