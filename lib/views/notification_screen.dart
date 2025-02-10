import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  static const String id = "Notification_Screen";

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Lottie.asset("assets/animations/No_Notification.json"),
                Text("Oops!!! no notification found", style: poppins_bold.copyWith(
                  fontSize: 17
                ),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
