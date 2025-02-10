import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/structure/enums/OrderStatus.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/register_vehicle_screen.dart';
import 'package:backcaps_logistics/views/source_destination_screen.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:backcaps_logistics/structure/Order.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/utils/text_handler.dart';
import '../../../../core/utils/utils.dart';
import '../../../../structure/Vehicle.dart';
import '../../../../widgets/static_widgets.dart';
import '../../../core/controllers/job_controller.dart';
import '../../../core/controllers/order_controller.dart';
import '../../../core/controllers/user_controller.dart';
import '../../../structure/Job.dart';
import '../../../structure/Organization.dart';
import '../../../widgets/send_parcel/special_delivery_card.dart';
import '../customer_screens/order_confirmation/confirm_nearyby_order.dart';

class OrganizationCard extends StatefulWidget {
  final Organization organization;
  final bool isOrder;
  Order? order;
  OrganizationCard({super.key, required this.organization, required this.isOrder, this.order});

  @override
  State<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends State<OrganizationCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserControllerProvider>(
        builder: (context, userControllerProvider, _) {
      return FutureBuilder(
          future: userControllerProvider
              .getUserById(widget.organization.organizationId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              Fluttertoast.showToast(
                  msg: "Error fetching organization record, contact developer");
              return Container();
            } else if (snapshot.hasData) {
              final user = snapshot.data;
              return GestureDetector(
                onTap: () => setState(() => isSelected = !isSelected),
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
                            borderRadius:
                                BorderRadius.circular(kDefaultRounding),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Text(widget.organization.name,
                                        style: roboto_bold.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildCustomFeatureIconRow(
                                          title: "Rating",
                                          content: user.rating.toString(),
                                          icon: Icons.star,
                                        ),
                                        buildCustomFeatureIconRow(
                                          title: "Vehicles",
                                          content: widget
                                              .organization.numberOfVehicles
                                              .toString(),
                                          icon: MdiIcons.truckOutline,
                                        ),
                                        buildCustomFeatureIconRow(
                                          title: "Category",
                                          content: "Big Company",
                                          icon: MdiIcons.shapeOutline,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child:
                                    user.imageUrl == "NULL" ? Image.asset('assets/images/logos/app_icon.png'): Image(image: NetworkImage(user.imageUrl)),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const RadialGradientDivider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      buildLongButton(context,
                                          filled: true,
                                          title: "Select",
                                          onPressed: () {
                                            showDialog(context: context, builder: (context){
                                              return AlertDialog(
                                                title: const Text("Please confirm your request."),
                                                content: Text(!widget.isOrder? "Are you sure you want to apply to this company?. Your credentials will automatically be shared to the respective organization.": "Are you sure you want to place order in this organization?\n Note: The organization will select the respective vehicle."),
                                                actions: [
                                                  TextButton(
                                                      onPressed: !widget.isOrder ? (){
                                                    Job newJob = Job(
                                                        jobRequest: FirebaseAuth.instance.currentUser!.uid,
                                                        jobRequestTo: widget.organization.organizationId,
                                                        jobType: "Worker",
                                                        startDate:
                                                        DateTime.now().toString(),
                                                        status: "Pending"
                                                    );
                                                    Provider.of<JobControllerProvider>(
                                                        context,
                                                        listen: false)
                                                        .createJob(newJob);
                                                    Fluttertoast.showToast(msg: "Your job request has been placed.");
                                                    Navigator.pop(context);
                                                  } : () async {
                                                        print(widget.order);
                                                        if(widget.order!=null){
                                                          final order = widget.order;
                                                          final user = await Provider.of<UserControllerProvider>(context, listen: false).getUser();
                                                          order?.customerName = user.name;
                                                          order?.customerImage = user.imageUrl;
                                                          order?.status = OrderStatus.WaitApproval;
                                                          order?.organizationId = widget.organization.organizationId;
                                                          order?.orderId = DateTime.now().millisecondsSinceEpoch.toString();
                                                          Provider.of<OrderControllerProvider>(context, listen: false).deleteOrder(order!.orderId);
                                                          await Provider.of<OrderControllerProvider>(context, listen: false)
                                                              .createOrder(order);
                                                          Fluttertoast.showToast(msg: "Your order has been placed.");
                                                          Navigator.pushReplacement(context , MaterialPageRoute(builder: (context)=> ConfirmNearByScreen(card: Container(), price: order.price, name: user.name, address: user.location.address,city: user.location.address)));
                                                        }
                                                        // Navigator.pop(context);
                                                      }, child: const Text("Confirm")),
                                                  TextButton(onPressed: (){
                                                    Navigator.pop(context);
                                                  }, child: const Text("Cancel"))
                                                ],
                                              );
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
            } else {
              return const SizedBox(
                height: 250,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          });
    });
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
