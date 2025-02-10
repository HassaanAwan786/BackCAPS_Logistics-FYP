import 'dart:async';
import 'dart:io';
import 'package:backcaps_logistics/core/constants/asset_image_lists.dart';
import 'package:backcaps_logistics/core/controllers/order_controller.dart';
import 'package:backcaps_logistics/views/supporting/location_screen.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:backcaps_logistics/views/supporting/scan_qr_screen.dart';
import 'package:backcaps_logistics/widgets/custom_scan_icon_button.dart';
import 'package:backcaps_logistics/widgets/edit_image_popup_view.dart';
import 'package:cnic_scanner/cnic_scanner.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../structure/Customer.dart';
import '../structure/Driver.dart';
import '../structure/Location.dart';
import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/widgets/custom_outlined_text_field.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/controllers/user_controller.dart';
import '../structure/User.dart';
import '../structure/enums/Role.dart';

class ProfileScreen extends StatefulWidget {
  final bool isDriverRequesting;
  const ProfileScreen({super.key, required this.isDriverRequesting});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int numberOfOrders = 0;
  final _formKey = GlobalKey<FormState>();
  final _nameField = TextFieldController();
  final _phoneField = TextFieldController();
  final _cnicField = TextFieldController();
  final _locationField = TextFieldController();
  double latitude = 0.0;
  double longitude = 0.0;
  final _drivingLicense = TextFieldController();
  int cnicFieldLength = 0;
  bool loadData = false;
  bool isPhoneVerified = false;
  bool isLoading = false;
  late dynamic user;
  bool isDriverLicenseScanned = false;
  bool isCNICScanned = false;
  File? image;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

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
        setState(() {
          isLoading = false;
          isPhoneVerified = true;
        });
      } else {
        setState(() => isLoading = false);
        throw Exception("Invalid code entered");
      }
    } catch (e) {
      Utils.showAlertPopup(context, "Something went wrong", e.toString());
    }
  }

  Future<void> getTotalOrders() async {
    final orders = await Provider.of<OrderControllerProvider>(context, listen: false).getCustomerOrders();
    numberOfOrders = orders.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Consumer<UserControllerProvider>(
              builder: (context, userControllerProvider, _) {
                return FutureBuilder(
                  future: userControllerProvider.getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Utils.showAlertPopup(context, "Something went wrong",
                          "Could not establish the connection");
                    } else if (snapshot.hasData) {
                      user = snapshot.data;
                      if (!loadData) {
                        _nameField.controller.text = user.name;
                        if (user.phoneNumber != "NULL") {
                          _phoneField.controller.text = user.phoneNumber;
                        }
                        if (user.cnic == "NULL") {
                          cnicFieldLength = 0;
                        } else {
                          isCNICScanned = true;
                          _cnicField.controller.text = user.cnic;
                          cnicFieldLength = user.cnic.length;
                        }
                        if (user.location.address != "NULL") {
                          _locationField.controller.text = user.location.address;
                        }
                        isPhoneVerified = user.phoneVerified;
                        loadData = true;
                        if(user.role == "Role.Driver"){
                          if(user.license != "NULL"){
                              isDriverLicenseScanned = true;
                              _drivingLicense.controller.text = user.license;
                          }
                        }
                        latitude = user.location.latitude;
                        longitude = user.location.longitude;
                      }
                      DateTime dateTime = DateTime.parse(user.registrationTime);
                      DateTime now = DateTime.now();
                      int differenceInDays = now.difference(dateTime).inDays;
                      if (user.role == "Role.Customer")getTotalOrders();
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: SingleChildScrollView(
                              child: Stack(
                                children: [
                                  !widget.isDriverRequesting ? IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded),
                                  ) : IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Provider.of<UserControllerProvider>(context, listen: false)
                                          .updateRole(Role.Customer);
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) => const RedirectUser()));
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        buildProfileImage(context),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            buildFeatureBox(
                                              context,
                                              title: user.role == "Role.Customer"
                                                  ? numberOfOrders.toString()
                                                  : user.totalDeliveries.toString(),
                                              content: user.role == "Role.Customer"
                                                  ? "Orders"
                                                  : "Deliveries",
                                            ),
                                            buildFeatureBox(
                                              context,
                                              // title: DateFormat("yyyy-MM-dd hh:mm:ss").parse(user.registrationTime).day.toString(),
                                              title: differenceInDays.toString(),
                                              content: "Days",
                                            ),
                                            buildFeatureBox(
                                              context,
                                              title: user.rating.toString(),
                                              content: "Rating",
                                            ),
                                          ],
                                        ),
                                        const SectionTitle(title: "Basic Info"),
                                        buildTextFields(),
                                        Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CustomPrimaryButton(
                                                isBold: false,
                                                onPressed: () async {
                                                  //This validates the fields
                                                  if (!await validateEmptiness()) {
                                                    return;
                                                  }
                                                  //Following check the field changes and ask confirmation
                                                  if (checkChangeInFields()) {
                                                    Utils.showConfirmationDialogue(
                                                        context,
                                                        title: "Save new data",
                                                        content:
                                                            "Are you sure you want to save the changes?",
                                                        confirmText: "Save",
                                                        onConfirm: () async {
                                                          setState(() {
                                                            isLoading = true;
                                                          });
                                                          if(user.cnic != _cnicField.controller.text ||
                                                              (user.cnic == "NULL" && _cnicField.controller.text.isNotEmpty)){
                                                            if(!await Provider.of<UserControllerProvider>(context, listen: false).checkSameCNIC(_cnicField.controller.text)){
                                                              Utils.showAlertPopup(context, "Oops!!! Similar CNIC already registered", "We have found that the same CNIC is already registered. Please retry or try login with other account with this cnic.");
                                                              setState(() => isLoading  = false);
                                                              return;
                                                            }
                                                          }
                                                          late String imageUrl;
                                                          if(image!=null){
                                                            imageUrl =
                                                                await uploadImage();
                                                          }else {
                                                            imageUrl = user.imageUrl;
                                                          }
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                          confirmSave(
                                                                context, imageUrl);
                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Changes saved successfully.")));
                                                        },
                                                        cancelText: "Cancel");
                                                  }else{
                                                    Utils.showAlertPopup(context, "Oops!!!", "You haven't changed anything.");
                                                  }
                                                },
                                                label: "Save",
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                );
              },
            ),
          ),
          loadingBackgroundBlur(isLoading),
          loadingIndicator(context, isLoading),
        ],
      ),
    );
  }

  void confirmSave(BuildContext context, String imageUrl) {
    late final editUser;
    final newUser = User(
        imageUrl: imageUrl,
        cnic: _cnicField.controller.text.isEmpty
            ? "NULL"
            : _cnicField.controller.text,
        email: user.email,
        location: Location(
            address: _locationField.controller.text.isEmpty
                ? "NULL"
                : _locationField.controller.text,
            longitude: longitude,
            latitude: latitude),
        name: _nameField.controller.text,
        phoneNumber: _phoneField.controller.text.isEmpty
            ? "NULL"
            : _phoneField.controller.text,
        phoneVerified:
            _phoneField.controller.text.isNotEmpty ? isPhoneVerified : false,
        rating: user.rating,
        registrationTime: user.registrationTime,
        role: user.role,
        username: user.username);
    if (user.role == "Role.Customer") {
      editUser = Customer.fromUser(
        newUser,
        customerID: user.customerID,
        numberOfOrders: user.numberOfOrders,
      );
    } else if (user.role == "Role.Driver") {
      // late String id;
      // if(user.driverID == "NULL"){
      //   id = user.customerID;
      // }else{
      //   id = user.driverID;
      // }
      editUser = Driver.fromUser(
        newUser,
        driverID: user.driverID,
        license: _drivingLicense.controller.text,
        totalDeliveries: user.totalDeliveries,
        totalVehicles: user.totalVehicles,
        verified: true,
      );
    } else {
      editUser = newUser;
    }
    Provider.of<UserControllerProvider>(context, listen: false)
        .updateUser(editUser.toJson());
  }

  bool checkChangeInFields() {
    return user.name != _nameField.controller.text ||
        user.phoneNumber != _phoneField.controller.text ||
        (user.phoneNumber == "NULL" &&
            _phoneField.controller.text.isNotEmpty) ||
        user.cnic != _cnicField.controller.text ||
        (user.cnic == "NULL" && _cnicField.controller.text.isNotEmpty) ||
        user.location.address != _locationField.controller.text ||
        (user.location.address == "NULL" &&
            _locationField.controller.text.isNotEmpty) ||
        image != null;
  }

  Widget buildProfileImage(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(190),
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.width / 4,
                  child: image == null
                      ? user.imageUrl == "NULL"
                      ? const Image(
                          image:
                              AssetImage("assets/images/avatars/user_02a.png"),
                        ) : Image(image: NetworkImage(user.imageUrl))
                      : Image.file(image!),
                  // backgroundImage: const AssetImage("assets/images/avatars/user_02a.png"),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton.filledTonal(
                  onPressed: () async {
                    final newImage = await showEditImagePopup(
                      context,
                      image,
                      title: "Select Person Avatar",
                      list: AvatarImageList,
                      presetImageLocation: "assets/images/avatars/group.png",
                    );
                    if (newImage != null) {
                      setState(() {
                        image = newImage;
                      });
                    }
                  },
                  icon: const Icon(Icons.edit),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(user.username, style: poppins_bold),
          const SizedBox(height: 5),
          Text(user.email, style: poppins),
          const RadialGradientDivider(),
        ],
      ),
    );
  }

  Widget buildFeatureBox(BuildContext context,
      {required String title, required String content}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(kDefaultRounding),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(title, style: poppins.copyWith(fontSize: 28)),
                Text(content, style: roboto_bold)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomOutlinedTextField(
              context,
              icon: const Icon(Icons.person_outline),
              textFieldController: _nameField,
              label: "Full Name",
              validator: validatorFunction("name is required"),
            ),
            const SizedBox(height: 15),
            CustomOutlinedTextField(context,
                isNumber: true,
                icon: null,
                textFieldController: _phoneField,
                label: "Phone Number",
                placeholder: "----------",
                type: TextInputType.phone,
                suffixIcon: isPhoneVerified ? Icons.verified : Icons.do_disturb,
                suffixIconColor: isPhoneVerified ? Colors.green : Colors.red,
                validator: validatorFunction("phone is required"),
                onSuffixPressed: () async {
                  if (_phoneField.controller.text[0] == '0') {
                    _phoneField.controller.text = _phoneField.controller.text.substring(1);
                  }
                  if (_phoneField.controller.text.length != 10) {
                    Utils.showAlertPopup(context, "Oops!! Something went wrong",
                        "Invalid phone number entered.");
                    return;
                  }
                  await handlePhoneNumberVerification();
            }, onChanged: (value) {
              setState(() {
                if (value != user.phoneNumber) {
                  isPhoneVerified = false;
                } else {
                  isPhoneVerified = true;
                }
              });
            }),
            const SizedBox(height: 15),
            CustomOutlinedTextField(context,
                icon: const Icon(Icons.assignment_ind_outlined),
                textFieldController: _cnicField,
                label: "CNIC",
                placeholder: "----- ------- -",
                suffixIcon: isCNICScanned ? Icons.verified : Icons.do_disturb,
                suffixIconColor: isCNICScanned ? Colors.green : Colors.red,
                validator: validatorFunction("cnic is required"),
                onSuffixPressed: () async {
                  setState(()=> isLoading = true);
                  ImageSource? source = await showScanPopup(context);
                  final data =
                      await CnicScanner().scanImage(imageSource: source);
                  setState(() {
                    _cnicField.controller.text = data.cnicNumber;
                    _nameField.controller.text = data.cnicHolderName;
                    if (_cnicField.controller.text.isNotEmpty &&
                        data.cnicNumber.isNotEmpty) {
                      isCNICScanned = true;
                    }
                  setState(()=> isLoading = false);
                  });
                },
                type: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    if (value != user.cnic) {
                      isCNICScanned = false;
                    } else {
                      isCNICScanned = true;
                    }
                    int length = _cnicField.controller.text.length;
                    if (length >= cnicFieldLength) {
                      if (length == 5) {
                        _cnicField.controller.text += "-";
                      }
                      if (length == 13) {
                        _cnicField.controller.text += "-";
                      }
                      if (length > 15) {
                        _cnicField.controller.text =
                            _cnicField.controller.text.substring(0, length - 1);
                      }
                    }
                    cnicFieldLength = length;
                  });
                }),
            user.role == "Role.Driver" ? const Gap(15) : Container(),
            user.role == "Role.Driver"
                ? Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: CustomOutlinedTextField(
                            context,
                            icon: Icon(MdiIcons.noteTextOutline),
                            textFieldController: _drivingLicense,
                            label: "License Number",
                            placeholder: "Scan license card",
                            readOnly: true,
                            suffixIcon: isDriverLicenseScanned
                                ? Icons.verified
                                : Icons.do_disturb,
                            suffixIconColor: isDriverLicenseScanned
                                ? Colors.green
                                : Colors.red,
                            validator: validatorFunction("license is required"),
                          )),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 1,
                        child: CustomScanIconButton(
                          onPressed: () async {
                            if (!isCNICScanned) {
                              Utils.showAlertPopup(context, "Scan CNIC first",
                                  "To scan the license you must scan the CNIC first.");
                              return;
                            }
                            setState(() {
                              isLoading = true;
                            });
                            final scannedData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ScanQRScreen()));
                            setState(() {
                              isLoading = false;
                            });
                            if (scannedData != null) {
                              //225526 ASIF MEHMOOD 37303-0720077-5
                              if (scannedData.length > 15) {
                                String ans = scannedData.substring(
                                    scannedData.length - 15,
                                    scannedData.length);
                                if (ans == _cnicField.controller.text) {
                                  setState(() {
                                    _drivingLicense.controller.text =
                                        scannedData.substring(0, 6);
                                    isDriverLicenseScanned = true;
                                  });
                                } else {
                                  Utils.showAlertPopup(
                                      context,
                                      "Invalid License Code 0x202",
                                      "Sorry your driving license is invalid. Error: Cnic and License don't match.");
                                }
                              } else {
                                Utils.showAlertPopup(
                                    context,
                                    "Something went wrong",
                                    "You scanned an invalid QR");
                                return;
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : Container(),
            const Gap(15),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomOutlinedTextField(
                    context,
                    icon: const Icon(Icons.location_on_outlined),
                    textFieldController: _locationField,
                    label: "Location",
                    placeholder: "Set your location",
                    type: TextInputType.text,
                    readOnly: true,
                    validator: validatorFunction("location is required"),
                  ),
                ),
                const Gap(5),
                Expanded(
                  flex: 1,
                  child: IconButton.filledTonal(
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ))),
                      onPressed: () async {
                        final address = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LocationScreen()));
                        setState(() {
                          _locationField.controller.text = address;
                          latitude = currentUserAddress.latitude;
                          longitude = currentUserAddress.longitude;
                        });
                      },
                      icon: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Column(
                          children: [
                            const Icon(Icons.location_on_outlined),
                            Text("Map", style: poppins.copyWith(fontSize: 14.0))
                          ],
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> validateEmptiness() async {
    if (_formKey.currentState!.validate()) {
      if (_phoneField.controller.text[0] == '0') {
        _phoneField.controller.text = _phoneField.controller.text.substring(1);
      }
      if (_phoneField.controller.text.length != 10) {
        Utils.showAlertPopup(context, "Oops!! Something went wrong",
            "Invalid phone number entered.");
        return false;
      }
      if (!isPhoneVerified) {
        await handlePhoneNumberVerification();
      }
    } else {
      return false;
    }
    return true;
  }

  Future<String> uploadImage() async {
    if (image != null) {
      final url =
          await Provider.of<UserControllerProvider>(context, listen: false)
              .uploadImage(image);
      return url;
    }
    return "NULL";
  }
}
