import 'dart:ui';

import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/structure/enums/Role.dart';
import 'package:backcaps_logistics/views/FindJobScreen.dart';
import 'package:backcaps_logistics/views/order_history.dart';
import 'package:backcaps_logistics/views/profile_screen.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:backcaps_logistics/views/track_customer_order.dart';
import 'package:backcaps_logistics/views/track_order_screen.dart';
import 'package:backcaps_logistics/widgets/drawer_items.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../core/controllers/user_controller.dart';
import '../core/utils/utils.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<UserControllerProvider>(
          builder: (context, userControllerProvider, _) {
            return FutureBuilder(
                future: userControllerProvider.getUser(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final user = snapshot.data;
                    // user = userControllerProvider.getUser();
                    return Drawer(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              buildProfileStack(context, user),
                              DrawerItem(
                                  icon: Icons.location_on_outlined,
                                  text: "Track Order",
                                  onTap: () {
                                    if(user.role == "Role.Customer"){
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const TrackCustomerOrder()));
                                    }else{
                                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const TrackOrderScreen()));
                                    }
                                  }),
                              DrawerItem(
                                icon: Icons.history,
                                text: "History",
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              OrderHistory(role: user.role)));
                                },
                              ),
                              DrawerItem(
                                icon: Icons.work_outline,
                                text: "Find a Job",
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>FindJobScreen()));
                                },
                              ),
                            ],
                          ),
                          SafeArea(
                              top: false,
                              child: Column(
                                children: [
                                  DrawerItem(
                                    icon: user.role == "Role.Customer"
                                        ? Icons.drive_eta_outlined
                                        : Icons.person_2_outlined,
                                    text: user.role == "Role.Customer"
                                        ? "Switch to Driver mode"
                                        : "Switch to Customer mode",
                                    onTap: () {
                                      Utils.showConfirmationDialogue(
                                        context,
                                        title: "Are you sure?",
                                        content: user != null
                                            ? "Please confirm switching to ${user.role == "Role.Customer" ? "driver mode" : "customer mode"}."
                                            : "User information unavailable.",
                                        confirmText: "Switch",
                                        onConfirm: () async {
                                          try {
                                            setState(() {
                                              isLoading = true;
                                            });

                                            bool roleUpdated = await Provider.of<UserControllerProvider>(context, listen: false).updateRole(
                                              user.role == "Role.Customer" ? Role.Driver : Role.Customer,
                                            );

                                            if (roleUpdated) {
                                              if(user.role == "Role.Customer"){
                                              Navigator.pushReplacement(context,
                                                  MaterialPageRoute(builder: (context) => const RedirectUser()));
                                              }
                                            } else {
                                              throw Exception("Role update failed");
                                            }
                                          } catch (e) {
                                            Fluttertoast.showToast(
                                              msg: "Something went wrong!!!: $e",
                                              timeInSecForIosWeb: 5,
                                            );

                                            if (mounted) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            }
                                          }
                                        },
                                        cancelText: "Discard",
                                      );
                                    },
                                  ),
                                  // DrawerItem(
                                  //   icon: Icons.location_city_outlined,
                                  //   text: "Register a Company",
                                  //   onTap: () {},
                                  // ),
                                  DrawerItem(
                                    icon: Icons.logout,
                                    text: "Logout",
                                    textStyle: poppins_bold,
                                    onTap: () {
                                      Provider.of<UserControllerProvider>(
                                              context,
                                              listen: false)
                                          .signOutUser();
                                    },
                                  ),
                                ],
                              )),
                        ],
                      ),
                    );
                  } else {
                    return const Drawer(
                        child: Center(child: CircularProgressIndicator()));
                  }
                });
          },
        ),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading),
      ],
    );
  }

  Stack buildProfileStack(BuildContext context, dynamic user) {
    return Stack(
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: 363,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF552131), Colors.transparent]),
            )),
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 30, right: 30),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(200),
                    child: CircleAvatar(
                      radius: MediaQuery.of(context).size.width / 4,
                      child: user.imageUrl != "NULL"
                          ? Image(image: NetworkImage(user.imageUrl))
                          : const Image(
                              image: AssetImage(
                                  "assets/images/avatars/user_02a.png")),
                      // backgroundImage:
                      //     const AssetImage("assets/images/avatars/user_02a.png"),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(user.username,
                        style: roboto_bold.copyWith(fontSize: 16)),
                    IconButton.filledTonal(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen(
                                      isDriverRequesting: false,
                                    ))),
                        icon: const Icon(Icons.edit)),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(user.email, style: poppins),
                ),
                const RadialGradientDivider(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
