import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/register_vehicle_screen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/text_handler.dart';
import '../../../../core/utils/utils.dart';
import '../../../../structure/Vehicle.dart';
import '../../../../widgets/static_widgets.dart';

class VehicleCard extends StatefulWidget {
  final Vehicle vehicle;
  final bool selectable;
  // final bool isSelected;

  const VehicleCard(
      {super.key, required this.vehicle, required this.selectable});

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => widget.selectable? isSelected = !isSelected : null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(kDefaultRounding)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(kDefaultRounding),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(widget.vehicle.model,
                              style: roboto_bold.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary)),
                          // const SizedBox(width: 10),
                          // Icon(
                          //   Icons.verified,
                          //   color: Colors.green,
                          // ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  //Main column
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            // column of rating, offered veh.
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildCustomFeatureIconRow(
                                title: "Category",
                                content: widget.vehicle.category,
                                icon: MdiIcons.truckFlatbed,
                              ),
                              buildCustomFeatureIconRow(
                                title: "Max Speed",
                                content:
                                    "${widget.vehicle.maxSpeed.toString()} km/h",
                                icon: Icons.speed_sharp,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Image(image: NetworkImage(widget.vehicle.image)),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        buildCustomFeatureIconRow(
                          title: "Fuel Capacity",
                          content:
                              "${widget.vehicle.fuelCapacity.toString()} LTR",
                          icon: Icons.water_drop_outlined,
                        ),
                        const Gap(10),
                        buildCustomFeatureIconRow(
                          title: "Max Load",
                          content:
                              "${widget.vehicle.containerCapacity.maxWeight.toString()} KG",
                          icon: MdiIcons.trayArrowDown,
                        ),
                      ],
                    ),
                    !isSelected
                        ? Container()
                        : Column(
                            children: [
                              const RadialGradientDivider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  buildTextIconButton(label: "Edit", icon: Icons.edit_outlined, onPressed: (){
                                    Navigator.push(context, MaterialPageRoute(
                                        builder: (context) =>
                                            AddVehicleScreen(
                                                vehicle:
                                                widget.vehicle,
                                            isDriverRequesting: false)));
                                  }),
                                  buildTextIconButton(label: "Delete", icon: Icons.delete_outline, onPressed: (){
                                    Utils.showConfirmationDialogue(context, title: "Are you sure?", content: "Please confirm the deletion of vehicle.", confirmText: "Delete", cancelText: "Cancel", onConfirm: (){
                                        Provider.of<VehicleControllerProvider>(context, listen: false).deleteVehicle(widget.vehicle!.id);
                                    });
                                  }),
                                ],
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextIconButton({
    required String label,
    required IconData icon,
    required Function() onPressed,
  }) {
    return Column(
      children: [
        IconButton.filled(onPressed: onPressed, icon: Icon(icon)),
        Text(
          label,
          style: poppins_bold,
        ),
      ],
    );
  }
}
