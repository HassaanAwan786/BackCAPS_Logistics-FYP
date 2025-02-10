import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/controllers/order_controller.dart';
import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/views/supporting/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:backcaps_logistics/structure/User.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/utils.dart';
import '../../../structure/Order.dart';
import '../../../structure/enums/OrderStatus.dart';
import '../../../widgets/static_widgets.dart';
import '../../notification_screen.dart';
import 'customer_home_screen.dart';
import '../../../structure/User.dart' as structure;

class buildHomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const buildHomeScreen({super.key, required this.scaffoldKey});

  @override
  State<buildHomeScreen> createState() => _buildHomeScreenState();
}

class _buildHomeScreenState extends State<buildHomeScreen> {
  String name = "Loading...";
  late dynamic user;
  double userRating = 0.0;
  bool firstRun = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserControllerProvider>(
      builder: (context, userControllerProvider, _) {
        return FutureBuilder(
          future: userControllerProvider.getUser(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Utils.showAlertPopup(context, "Something went wrong",
                  "Could not establish the connection.");
            } else if (snapshot.hasData) {
              user = snapshot.data;
              return CustomScrollView(slivers: [
                _buildAppBar(context, scaffoldKey: widget.scaffoldKey),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionTitle(title: "Select your order"),
                          SelectOrderRow(),
                          SectionTitle(title: "Choose your option"),
                          BuildOptionRow(role: user.role),
                          Consumer<OrderControllerProvider>(
                            builder: (context, orderControllerProvider, _) {
                              return FutureBuilder(
                                  future: orderControllerProvider
                                      .getCustomerOrders(),
                                  builder: (context, snapshot) {
                                    if(snapshot.hasError){
                                      Fluttertoast.showToast(msg: "Something went wrong fetching orders, please contact developer.");
                                      return Container();
                                    }else if(snapshot.hasData){
                                      final orders = snapshot.data;
                                      List<Order> processingOrders = [];
                                      for(var order in orders!){
                                        if(order.status == OrderStatus.InProcess){
                                          print(order.toJson());
                                          processingOrders.add(order);
                                        }
                                        else if(order.status == OrderStatus.Delivered && firstRun){
                                            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                              showDialog(context: context, builder: (context){
                                                return FutureBuilder(future: userControllerProvider.getUserById(order.driverId), builder: (context, snapshot){
                                                  if(snapshot.hasError){
                                                    Fluttertoast.showToast(msg: "Error fetching driver, contact developer");
                                                    return Container();
                                                  }
                                                  else if(snapshot.hasData){
                                                    final driver = snapshot.data!;
                                                    return AlertDialog(
                                                      title: Text('Rate Driver'),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          CircleAvatar(
                                                            radius: 40,
                                                            backgroundImage: NetworkImage(driver.imageUrl),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Text(driver.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                          SizedBox(height: 10),
                                                          Text('Current Rating: ${driver.rating}'),
                                                          SizedBox(height: 10),
                                                          RatingBar.builder(
                                                            initialRating: 0,
                                                            minRating: 1,
                                                            direction: Axis.horizontal,
                                                            allowHalfRating: true,
                                                            itemCount: 5,
                                                            itemBuilder: (context, _) => Icon(
                                                              Icons.star,
                                                              color: Colors.amber,
                                                            ),
                                                            onRatingUpdate: (rating) {
                                                                userRating = rating;
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            final currentDeliveries = driver.totalDeliveries + 1;
                                                            final previousTotalRating = driver.rating * driver.totalDeliveries;
                                                            final newTotalRating = previousTotalRating + userRating;
                                                            final newRating = newTotalRating / currentDeliveries;
                                                            final updateDriver = driver;
                                                            updateDriver.rating = newRating;
                                                            updateDriver.totalDeliveries = currentDeliveries;
                                                            Provider.of<UserControllerProvider>(context, listen: false).updateUserById(updateDriver.toJson(), order.driverId);
                                                            order.status = OrderStatus.Rated;
                                                            Provider.of<OrderControllerProvider>(context, listen: false).update(order);
                                                            Fluttertoast.showToast(msg: "Driver rated successfully.");
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text('Submit'),
                                                        ),
                                                      ],
                                                    );
                                                  }
                                                  else {
                                                    return const SizedBox(height:250, child:Center(child:CircularProgressIndicator()));
                                                  }
                                                });
                                              });
                                            });
                                            firstRun = false;
                                        }
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if(processingOrders.isNotEmpty) const SectionTitle(title: "Current Shipping"),
                                          ...List.generate(processingOrders.length, (index){
                                            return ShippingCard(order: processingOrders[index]);
                                          }),

                                        ],
                                      );
                                    }else{
                                      return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                                    }
                                  });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        );
      },
    );
  }

  Widget _buildAppBar(context,
      {required GlobalKey<ScaffoldState> scaffoldKey}) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      toolbarHeight: 60,
      leadingWidth: 60,
      leading: Ink(
        child: InkWell(
          onTap: () =>
              setState(() => widget.scaffoldKey.currentState!.openDrawer()),
          child: Container(
            width: 53,
            height: 53,
            // margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.only(left: 10.0),
            child: user.imageUrl != "NULL"
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(user.imageUrl),
                  )
                : const CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage("assets/images/avatars/user_02a.png"),
                  ),
          ),
        ),
      ),
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hello",
              style: TextStyle(fontFamily: poppins.fontFamily, fontSize: 14)),
          Text(user.name,
              style: TextStyle(
                  fontFamily: poppins.fontFamily,
                  fontSize: 14,
                  fontWeight: poppins_bold.fontWeight)),
        ],
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.all(6.0),
      //     child: IconButton.filledTonal(
      //         onPressed: () {
      //           Navigator.push(
      //               context,
      //               MaterialPageRoute(
      //                   builder: (context) => NotificationScreen()));
      //         },
      //         icon: const Icon(Icons.notifications_outlined)),
      //   ),
      // ],
    );
  }
}
