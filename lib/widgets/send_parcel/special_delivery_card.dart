import 'package:backcaps_logistics/core/controllers/order_controller.dart';
import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/structure/enums/OrderStatus.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/order_confirmation/confirm_nearyby_order.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
import '../../structure/Order.dart';

class SpecialDeliveryCard extends StatefulWidget {
  final Order order;

  const SpecialDeliveryCard({super.key, required this.order});

  @override
  State<SpecialDeliveryCard> createState() => _SpecialDeliveryCardState();
}

class _SpecialDeliveryCardState extends State<SpecialDeliveryCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserControllerProvider>(
      builder: (context, userControllerProvider, _) {
        return FutureBuilder(
            future: userControllerProvider.getUserById(widget.order.driverId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Utils.showAlertPopup(
                    context, "Something went wrong", ("Can't fetch user data"));
                return Container();
              } else if (snapshot.hasData) {
                final user = snapshot.data;
                if (user.userId == userControllerProvider.user.userId) {
                  return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(kDefaultRounding)),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                          "Sorry cannot process order approved by oneself."),
                    ),
                  );
                } else if (user.role == "Role.Customer") {
                  return Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(kDefaultRounding)),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Sorry, the driver is no longer present."),
                    ),
                  );
                }
                return Ink(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(kDefaultRounding)),
                  child: InkWell(
                    onTap: () => setState(() => isSelected = !isSelected),
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
                                      Text(user.name,
                                          style: roboto_bold.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary)),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.verified,
                                        color: Color(0xFFF61B3FF),
                                      ),
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
                                  // first row of rating, offered vehicle and image
                                  children: [
                                    Expanded(
                                      child: Column(
                                        // column of rating, offered veh.
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildCustomFeatureIconRow(
                                            title: "Rating",
                                            content: "${user.rating}/5",
                                            icon: Icons.star,
                                          ),
                                          buildCustomFeatureIconRow(
                                            title: "Offered Vehicle",
                                            content: widget.order.vehicleCategory,
                                            icon: MdiIcons.truckFlatbed,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Image(
                                          image: AssetImage(
                                              widget.order.vehicleCategory == "Pickup"
                                                  ? "assets/images/resources/pickup.png"
                                                  : widget.order.vehicleCategory == "Mini Truck"
                                                  ? "assets/images/resources/mini.png"
                                                  : widget.order.vehicleCategory == "2-Axle Truck"
                                                  ? "assets/images/resources/truck1.png"
                                                  : widget.order.vehicleCategory == "Large Truck"
                                                  ? "assets/images/resources/large.png"
                                                  : "assets/images/resources/question_truck.png")),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    buildCustomFeatureIconRow(
                                      title: "Category",
                                      content: "Personal Individual",
                                      icon: Icons.category_outlined,
                                    ),
                                    buildCustomFeatureIconRow(
                                      title: "Vehicles",
                                      content: "${user.totalVehicles} Total",
                                      icon: MdiIcons.truckOutline,
                                    ),
                                  ],
                                ),
                                const RadialGradientDivider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        user.imageUrl == "NULL" ? const CircleAvatar(
                                          backgroundImage: AssetImage(
                                              "assets/images/avatars/user_02a.png"),
                                        ) : CircleAvatar(
                                          backgroundImage: NetworkImage(user.imageUrl),
                                        ),
                                        const Gap(10),
                                        CustomGrandText(text: "Offered"),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Rs",
                                            style: poppins_bold.copyWith(
                                                fontSize: 24)),
                                        const SizedBox(width: 5),
                                        CustomVerticalDivider(
                                            height: 22.5,
                                            width: 2.5,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer),
                                        const SizedBox(width: 7),
                                        Text(widget.order.price.toString(),
                                            style: poppins_bold.copyWith(
                                                fontSize: 24)),
                                      ],
                                    ),
                                  ],
                                ),
                                isSelected
                                    ? const SizedBox(height: 5)
                                    : Container(),
                                !isSelected
                                    ? Container()
                                    : Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              kDefaultRounding),
                                          color: Theme.of(context)
                                              .colorScheme
                                              .background,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            MaterialButton(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          kDefaultRounding)),
                                              elevation: 0,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              onPressed: () {
                                                Provider.of<OrderControllerProvider>(context, listen: false).deleteOfferOrder(widget.order.orderId);
                                              },
                                              child: Text("Reject",
                                                  style: poppins_bold),
                                            ),
                                            MaterialButton(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          kDefaultRounding)),
                                              color: greenishColor,
                                              onPressed: () {
                                                Provider.of<OrderControllerProvider>(context, listen: false).deleteOfferOrder(widget.order.orderId);
                                                Order newOrder = widget.order;
                                                newOrder.status = OrderStatus.InProcess;
                                                newOrder.orderId = newOrder.orderId.split("_")[0];
                                                Provider.of<OrderControllerProvider>(context, listen: false).update(newOrder);
                                                Navigator.pushReplacement(context , MaterialPageRoute(builder: (context)=> ConfirmNearByScreen(card: SpecialDeliveryCard(order: widget.order), price: widget.order.price, name: user.name, address: user.location.address,city: user.location.address)));
                                              },
                                              child: Text("Accept",
                                                  style: poppins_bold),
                                            ),
                                          ],
                                        ),
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      },
    );
  }
}
