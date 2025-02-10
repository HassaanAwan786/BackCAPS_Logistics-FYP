import 'package:backcaps_logistics/core/controllers/order_controller.dart';
import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/customer_home_screen.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/find_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../core/constants/constants.dart';

class OrderHistory extends StatelessWidget {
  final String role;
  const OrderHistory({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
      ),
      body: Consumer<OrderControllerProvider>(
        builder: (context, orderControllerProvider, _) {
          return FutureBuilder(
            future: orderControllerProvider.getOrderHistory(role),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                Utils.showAlertPopup(context, "Something went wrong",
                    ("Somehow we cannot fetch order history. Please contact developer"));
                return Container();
              }
              else if (snapshot.hasData) {
                final orders = snapshot.data;
                if(orders!.isEmpty){
                  return Column(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Lottie.asset("assets/animations/No_Notification.json"),
                            Text("Oops!!! no orders found", style: poppins_bold.copyWith(
                                fontSize: 17
                            ),),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return Column(
                  children: [
                    ...List.generate(orders.length, (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ShippingCard(order: orders[index]),
                    ))
                  ],
                );
              }
              else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        },
      ),
    );
  }
}
