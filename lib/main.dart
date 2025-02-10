import 'dart:io';

import 'package:backcaps_logistics/core/constants/apiKeys.dart';
import 'package:backcaps_logistics/core/controllers/chat_controller.dart';
import 'package:backcaps_logistics/core/controllers/order_controller.dart';
import 'package:backcaps_logistics/core/controllers/organization_controller.dart';
import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/structure/theme/color_scheme.dart';
import 'package:backcaps_logistics/views/FindJobScreen.dart';
import 'package:backcaps_logistics/views/chat_screen.dart';
import 'package:backcaps_logistics/views/directive_home_screen.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/customer_home_screen.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/order_confirmation/confirm_nearyby_order.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/send_parcel_screens/send_parcel_screen.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/find_orders_screen.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/register_vehicle_screen.dart';
import 'package:backcaps_logistics/views/home_screens/owner_screens/home_screen.dart';
import 'package:backcaps_logistics/views/login_screen.dart';
import 'package:backcaps_logistics/views/notification_screen.dart';
import 'package:backcaps_logistics/views/payment.dart';
import 'package:backcaps_logistics/views/profile_screen.dart';
import 'package:backcaps_logistics/views/signup_screen.dart';
import 'package:backcaps_logistics/views/source_destination_screen.dart';
import 'package:backcaps_logistics/views/supporting/email_verification.dart';
import 'package:backcaps_logistics/views/supporting/forget_password_screen.dart';
import 'package:backcaps_logistics/views/supporting/phone_verification_screen.dart';
import 'package:backcaps_logistics/widgets/screen.dart';
import 'package:backcaps_logistics/widgets/send_parcel/special_delivery_card.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'core/controllers/job_controller.dart';
import 'core/controllers/user_controller.dart';
import 'firebase_options.dart';
import 'views/supporting/redirect_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  Stripe.publishableKey= STRIPE_PUBLISH_KEY;
  Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
  Stripe.urlScheme = 'flutterstripe';
  await Stripe.instance.applySettings();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserControllerProvider()),
          ChangeNotifierProvider(create: (context) => VehicleControllerProvider()),
          ChangeNotifierProvider(create: (context) => OrderControllerProvider()),
          ChangeNotifierProvider(create: (context) => ChatControllerProvider()),
          ChangeNotifierProvider(create: (context) => OrganizationControllerProvider()),
          ChangeNotifierProvider(create: (context) => JobControllerProvider()),
        ],
        child: const MyApp(),
      )
  );
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});



  @override
  Widget build(BuildContext context) {
    HttpOverrides.global = new MyHttpOverrides();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "BackCAPS Logistics",
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      // home: ConfirmNearByScreen(card: NearbyCard(priceController: new TextFieldController(), isSelected: false)),
      home: RedirectUser(),
      routes: {
        LoginScreen.id : (context) => const LoginScreen(),
        SignupScreen.id : (context) => const SignupScreen(),
      },
    );
  }
}
