import 'package:backcaps_logistics/views/drawer_screen.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/customer_home_screen.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/driver_home_screen.dart';
import 'package:backcaps_logistics/views/home_screens/owner_screens/home_screen.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final driverScreens = [
    const LoadDriverData()
  ];

  final ownerScreens = [
    LoadOwnerData()
  ];

  final customerScreens = [
    const CustomerHomeScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.role == "Role.Customer"
          ? customerScreens[selectedIndex]
          : widget.role == "Role.Driver"
          ? driverScreens[selectedIndex]
          : widget.role == "Role.Owner"
          ? ownerScreens[selectedIndex]
          : Container(),
    );
  }
}
