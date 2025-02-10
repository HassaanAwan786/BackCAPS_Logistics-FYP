import 'dart:async';
import 'dart:io';
import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/constants/asset_image_lists.dart';
import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/model/ImageProperties.dart';
import 'package:backcaps_logistics/structure/BoxContainer.dart';
import 'package:backcaps_logistics/structure/Vehicle.dart';
import 'package:backcaps_logistics/structure/VehiclePermit.dart';
import 'package:backcaps_logistics/widgets/custom_outlined_text_field.dart';
import 'package:backcaps_logistics/widgets/custom_scan_icon_button.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/controllers/user_controller.dart';
import '../../../core/utils/utils.dart';
import '../../../structure/enums/Role.dart';
import '../../../structure/enums/VehicleCategory.dart';
import '../../../widgets/custom_location_icon_button.dart';
import '../../../widgets/edit_image_popup_view.dart';
import '../../supporting/redirect_user.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;
  final bool isDriverRequesting;
  const AddVehicleScreen({super.key, this.vehicle, required this.isDriverRequesting});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  File? image;
  Color currentVehicleColor = Colors.grey;
  final _model = TextFieldController();
  final _speed = TextFieldController();
  final _engine = TextFieldController();
  String _category = "None";
  final _fuelCapacity = TextFieldController();
  final _maxLoad = TextFieldController();
  final _containerL = TextFieldController();
  final _containerW = TextFieldController();
  final _containerH = TextFieldController();
  final _permitNumber = TextFieldController();
  final _numberPlate = TextFieldController();
  bool isPermitVerified = false;
  bool isLoading = false;

  Future<void> getImageFromSource(ImageSource source) async {
    try {
      setState(() => isLoading = true);
      final imagePick = await picker.pickImage(source: source);
      final imageTemporary = File(imagePick!.path);
      setState(() => image = imageTemporary);
    } catch (e) {
      Utils.showAlertPopup(context, "Image Error", "Error: $e");
    }finally{
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.vehicle != null) {
      _model.controller.text = widget.vehicle!.model;
      _speed.controller.text = widget.vehicle!.maxSpeed.toString();
      _engine.controller.text = widget.vehicle!.engineHP.toString();
      _category = widget.vehicle!.category;
      _fuelCapacity.controller.text = widget.vehicle!.fuelCapacity.toString();
      _maxLoad.controller.text =
          widget.vehicle!.containerCapacity.maxWeight.toString();
      _containerL.controller.text =
          widget.vehicle!.containerCapacity.length.toString();
      _containerH.controller.text =
          widget.vehicle!.containerCapacity.height.toString();
      _containerW.controller.text =
          widget.vehicle!.containerCapacity.width.toString();
      _permitNumber.controller.text =
          widget.vehicle!.permit.permitNumber.toString();
      _numberPlate.controller.text =
          widget.vehicle!.permit.numberPlate.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.vehicle == null ? "Add Vehicle" : "Edit Vehicle"),
            leading: widget.isDriverRequesting
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Provider.of<UserControllerProvider>(context, listen: false)
                          .updateRole(Role.Customer);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RedirectUser()));
                    },
                  )
                : IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
          ),
          body: SafeArea(
              child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    image == null
                                        ? widget.vehicle == null
                                            ? Image(
                                                image: const AssetImage(
                                                    "assets/images/resources/question_truck.png"),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                              )
                                            : Image(
                                                image: NetworkImage(
                                                    widget.vehicle!.image),
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                              )
                                        : Image.file(image!,
                                            height:
                                                MediaQuery.of(context).size.width /
                                                    2),
                                    const Gap(10),
                                    FloatingActionButton.extended(
                                      elevation: 0,
                                      icon: const Icon(Icons.edit),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(40)),
                                      onPressed: () async {
                                        final newImage = await showEditImagePopup(
                                          context,
                                          image,
                                          title: 'Select Truck Image',
                                          list: TruckImageList,
                                          presetImageLocation:
                                              "assets/images/resources/vehicles.png",
                                        );
                                        if (newImage != null) {
                                          setState(() {
                                            image = newImage;
                                          });
                                        }
                                      },
                                      label: const Text("Edit Image"),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const FuturisticSectionTitle(
                                            title: "Basic Info"),
                                        const SizedBox(height: 10),
                                        CustomOutlinedTextField(context,
                                            suffixIcon: Icons.circle,
                                            suffixIconColor: currentVehicleColor,
                                            textFieldController: _model,
                                            label: "Made/ Model",
                                            placeholder: "Enter vehicle model",
                                            icon: Icon(MdiIcons.truckOutline),
                                            onSuffixPressed: () {
                                          ColorPicker(
                                            pickersEnabled: const {
                                              ColorPickerType.both: false,
                                              ColorPickerType.primary: true,
                                            },
                                            color: currentVehicleColor,
                                            onColorChanged: (color) {
                                              setState(() {
                                                currentVehicleColor = color;
                                              });
                                            },
                                          ).showPickerDialog(
                                            context,
                                            elevation: 15,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    kDefaultRounding)),
                                          );
                                        },
                                            validator: validatorFunction(
                                                "model is required")),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: CustomOutlinedTextField(
                                                  context,
                                                  textFieldController: _speed,
                                                  icon:
                                                      const Icon(Icons.speed_sharp),
                                                  label: "Max Speed",
                                                  placeholder: "Enter km/h",
                                                  suffixIcon: null,
                                                  validator: (value) {
                                                if (value!.isEmpty) {
                                                  return "max speed is required";
                                                } else if (!RegExp(
                                                        r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$')
                                                    .hasMatch(value)) {
                                                  return "speed must be numbers only";
                                                }
                                              }),
                                            ),
                                            const Gap(10),
                                            Expanded(
                                              flex: 2,
                                              child: CustomOutlinedTextField(
                                                context,
                                                textFieldController: _engine,
                                                label: "Engine (HP)",
                                                placeholder: "HP",
                                                suffixIcon: null,
                                                validator: validatorFunction(
                                                    "hp required"),
                                              ),
                                            )
                                          ],
                                        ),
                                        const Gap(10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Stack(children: [
                                                // Positioned(
                                                //   top: -10,
                                                //   child: Container(
                                                //     color: Theme.of(context).colorScheme.background,
                                                //     child: const Text("Category", style: TextStyle(fontSize: 12),),
                                                //   ),
                                                // ),
                                                Container(
                                                  height: 56,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onBackground
                                                              .withOpacity(0.5)),
                                                      borderRadius:
                                                          BorderRadius.circular(6)),
                                                  child: ListTile(
                                                    leading:
                                                        Icon(MdiIcons.truckFlatbed),
                                                    title: Text(_category == "None"
                                                        ? "Select Category"
                                                        : _category),
                                                    trailing: const Icon(
                                                        Icons.keyboard_arrow_down),
                                                    onTap: () {
                                                      showCupertinoModalPopup<void>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            Container(
                                                          height: 216,
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  top: 6.0),
                                                          margin: EdgeInsets.only(
                                                            bottom: MediaQuery.of(
                                                                    context)
                                                                .viewInsets
                                                                .bottom,
                                                          ),
                                                          color: CupertinoColors
                                                              .systemBackground
                                                              .resolveFrom(context),
                                                          child: SafeArea(
                                                            top: false,
                                                            child: CupertinoPicker(
                                                              magnification: 1.22,
                                                              squeeze: 1.2,
                                                              useMagnifier: true,
                                                              itemExtent: 32.0,
                                                              scrollController:
                                                                  FixedExtentScrollController(
                                                                initialItem: 0,
                                                              ),
                                                              onSelectedItemChanged:
                                                                  (int
                                                                      selectedItem) {
                                                                setState(() {
                                                                  _category =
                                                                      categoryList[
                                                                          selectedItem];
                                                                });
                                                              },
                                                              children: List<
                                                                      Widget>.generate(
                                                                  categoryList
                                                                      .length,
                                                                  (int index) {
                                                                return Center(
                                                                    child: Text(
                                                                        categoryList[
                                                                            index]));
                                                              }),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ]),
                                            ),
                                          ],
                                        ),
                                        // InkWell(
                                        //   onTap: () {
                                        //     print("On tap pressed");
                                        //     showCupertinoModalPopup<void>(
                                        //       context: context,
                                        //       builder: (BuildContext context) => Container(
                                        //         height: 216,
                                        //         padding: const EdgeInsets.only(top: 6.0),
                                        //         margin: EdgeInsets.only(
                                        //           bottom: MediaQuery.of(context)
                                        //               .viewInsets
                                        //               .bottom,
                                        //         ),
                                        //         color: CupertinoColors.systemBackground
                                        //             .resolveFrom(context),
                                        //         child: SafeArea(
                                        //           top: false,
                                        //           child: CupertinoPicker(
                                        //             magnification: 1.22,
                                        //             squeeze: 1.2,
                                        //             useMagnifier: true,
                                        //             itemExtent: 32.0,
                                        //             scrollController:
                                        //                 FixedExtentScrollController(
                                        //               initialItem: 0,
                                        //             ),
                                        //             onSelectedItemChanged:
                                        //                 (int selectedItem) {
                                        //               setState(() {
                                        //                 // packages = selectedItem + 1;
                                        //               });
                                        //             },
                                        //             children: List<Widget>.generate(100,
                                        //                 (int index) {
                                        //               return Center(
                                        //                   child: Text("${index + 1}"));
                                        //             }),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     );
                                        //   },
                                        //   child: Container(
                                        //     child: CustomOutlinedTextField(
                                        //       context,
                                        //       readOnly: true,
                                        //       textFieldController: _category,
                                        //       label: "Category",
                                        //       placeholder: "Mini truck (4x4)",
                                        //       icon: Icon(MdiIcons.truckFlatbed),
                                        //       suffixIcon: Icons.keyboard_arrow_down,
                                        //       suffixIconColor:
                                        //           Theme.of(context).colorScheme.onBackground,
                                        //       validator: validatorFunction(
                                        //           "vehicle category required"),
                                        //     ),
                                        //   ),
                                        // ),
                                        const Gap(10),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: CustomOutlinedTextField(
                                                  context,
                                                  textFieldController:
                                                      _fuelCapacity,
                                                  icon: Icon(MdiIcons.waterOutline),
                                                  label: "Fuel Capacity",
                                                  placeholder: "Enter LTR",
                                                  suffixIcon: null,
                                                  validator: validatorFunction(
                                                      "Fuel capacity is required")),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 2,
                                              child: CustomOutlinedTextField(
                                                context,
                                                type: TextInputType.number,
                                                textFieldController: _maxLoad,
                                                label: "Max Load",
                                                placeholder: "KG",
                                                suffixIcon: null,
                                                validator: validatorFunction(
                                                    "load is required"),
                                              ),
                                            )
                                          ],
                                        ),
                                        const FuturisticSectionTitle(
                                            title: "Container Capacity"),
                                        const Gap(8),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomOutlinedTextField(
                                                context,
                                                textFieldController: _containerL,
                                                icon: null,
                                                type: TextInputType.number,
                                                label: "Length",
                                                placeholder: "m",
                                                suffixIcon: null,
                                                validator: validatorFunction(
                                                    "field required"),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(Icons.close,
                                                size: 30,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground
                                                    .withOpacity(.5)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomOutlinedTextField(
                                                context,
                                                type: TextInputType.number,
                                                textFieldController: _containerW,
                                                label: "Width",
                                                placeholder: "m",
                                                suffixIcon: null,
                                                validator: validatorFunction(
                                                    "field required"),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Icon(Icons.close,
                                                size: 30,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground
                                                    .withOpacity(.5)),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: CustomOutlinedTextField(
                                                context,
                                                type: TextInputType.number,
                                                textFieldController: _containerH,
                                                label: "Height",
                                                placeholder: "m",
                                                suffixIcon: null,
                                                validator: validatorFunction(
                                                    "field required"),
                                              ),
                                            )
                                          ],
                                        ),
                                        const FuturisticSectionTitle(
                                            title: "Status"),
                                        const Gap(8),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: CustomOutlinedTextField(
                                                context,
                                                icon:
                                                    Icon(MdiIcons.noteTextOutline),
                                                textFieldController: _permitNumber,
                                                label: "Permit Number",
                                                placeholder: "Scan permit number",
                                                // suffixIcon: isPermitVerified
                                                //     ? Icons.verified
                                                //     : Icons.do_disturb,
                                                // suffixIconColor: isPermitVerified
                                                //     ? Colors.green
                                                //     : Colors.red,
                                                validator: validatorFunction(
                                                    "Permit is required"),
                                              ),
                                            ),
                                            // const Gap(10),
                                            // Expanded(
                                            //   flex: 1,
                                            //   child: CustomScanIconButton(
                                            //     onPressed: () {},
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        const Gap(10),
                                        CustomOutlinedTextField(
                                          context,
                                          icon: Icon(MdiIcons.cardTextOutline),
                                          textFieldController: _numberPlate,
                                          label: "Number Plate",
                                          placeholder: "Enter number plate",
                                          validator: validatorFunction(
                                              "Number plate is required"),
                                        ),
                                        const Gap(20),
                                        Row(
                                          children: [
                                            buildLongButton(
                                              context,
                                              filled: true,
                                              title: widget.vehicle == null
                                                  ? "Add Vehicle"
                                                  : "Edit Vehicle",
                                              onPressed:
                                                  onPressedVehiclePrimaryButton,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ))),
        ),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading),
      ],
    );
  }

  onPressedVehiclePrimaryButton() async {
    if (_formKey.currentState!.validate()) {
      if (_category == "None") {
        Utils.showAlertPopup(
            context, "Missing required field", "Vehicle category is required.");
        return;
      }
      //add all records to database
      final height = double.parse(_containerH.controller.text);
      final width = double.parse(_containerW.controller.text);
      final length = double.parse(_containerL.controller.text);
      final weight = double.parse(_maxLoad.controller.text);
      final engineHP = double.parse(_engine.controller.text);
      final newVehicle = Vehicle(
        image: widget.vehicle != null ? widget.vehicle!.image : "NULL",
        category: _category,
        containerCapacity: BoxContainer(
            height: height, length: length, maxWeight: weight, width: width),
        engineHP: engineHP,
        fuelCapacity: double.parse(_fuelCapacity.controller.text),
        model: _model.controller.text,
        maxSpeed: int.parse(_speed.controller.text),
        permit: VehiclePermit(
          numberPlate: _numberPlate.controller.text,
          permitNumber: _permitNumber.controller.text,
        ),
        isAvailable: false,
      );
      setState(() => isLoading = true);
      await Provider.of<VehicleControllerProvider>(context, listen: false)
          .checkSameNumberPlate(_numberPlate.controller.text, widget.vehicle)
          .then((sameNumberExists) async {
        //check for duplicate number plate;
        print(sameNumberExists);
        setState(() => isLoading = false);
        if (!sameNumberExists) {
          setState(() => isLoading = true);
          await uploadImage().then((url) async {
            setState(() => isLoading = false);
            if (url != "NULL") {
              print("storing in image $url");
              newVehicle.image = url;
            } else if (newVehicle.image == "NULL") {
              Utils.showAlertPopup(context, "Something went wrong",
                  "Image is required. Please reload image.");
              return;
            }
            setState(() => isLoading = true);
            widget.vehicle == null
                ? await Provider.of<VehicleControllerProvider>(context,
                        listen: false)
                    .createVehicle(newVehicle)
                    .then((createVehicle) async {
                    if (createVehicle) {
                      await Provider.of<UserControllerProvider>(context,
                              listen: false)
                          .incrementVehicleCount();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Vehicle registered successfully.")));
                      setState(() => isLoading = false);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Vehicle could not be added for the time.")));
                    }
                  })
                : await Provider.of<VehicleControllerProvider>(context,
                        listen: false)
                    .updateVehicle(widget.vehicle!.id, newVehicle)
                    .then((updateVehicle) {
                    if (updateVehicle) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Vehicle updated successfully.")));
                      Navigator.pop(context);
                    }
                  });
          });
        } else {
          Utils.showAlertPopup(context, "Something went wrong",
              "Number plate you entered is already registered to another owner.");
          return;
        }
      });
    }
  }

  Future<String> uploadImage() async {
    if (image != null) {
      final url =
          await Provider.of<VehicleControllerProvider>(context, listen: false)
              .uploadImage(image, _numberPlate.controller.text);
      return url;
    }
    return "NULL";
  }
}
