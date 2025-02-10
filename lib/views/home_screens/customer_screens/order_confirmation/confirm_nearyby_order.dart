import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/views/track_customer_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import '../../../../core/controllers/user_controller.dart';
import '../../../../widgets/static_widgets.dart';
import '../../../payment.dart';

class ConfirmNearByScreen extends StatefulWidget {
  final Widget card;
  final int price;
  final String name;
  final String address;
  final String city;
  const ConfirmNearByScreen({super.key, required this.card, required this.price, required this.name, required this.address, required this.city});

  static const String id = "Confirm_Nearby_Screen";

  @override
  State<ConfirmNearByScreen> createState() => _ConfirmNearByScreenState();
}

class _ConfirmNearByScreenState extends State<ConfirmNearByScreen> {
  bool paymentComplete = false;

  Future<void> initPaymentSheet() async {
    try {
      final data = await createPaymentIntent(
          amount: (widget.price*100).toString(),
          currency: "PKR",
          name: widget.name,
          address: widget.address,
          pin: "1234",
          city: widget.city,
          state: "Punjab",
          country: "Pakistan");


      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          merchantDisplayName: 'Test Merchant',
          paymentIntentClientSecret: data['client_secret'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],

          style: ThemeMode.light,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: null,
        actions: [
          IconButton(onPressed: (){
            if(!paymentComplete){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment is required")));
              return;
            }
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>TrackCustomerOrder()));
          }, icon: Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.onPrimary,)),
        ],
        title: Text(
          "Order Confirm",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),

      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomGrandText(
                text: "Your order has been placed",
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.verified_user_sharp,
                        color: Colors.green,
                        size: 148,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Thank you for your order",
                        style: poppins.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
              widget.card,
              const SizedBox(height: 10),
              CustomGrandText(text: "Payment Procedure"),
              const SizedBox(height: 10),
              // Center(
              //   child: FloatingActionButton.extended(
              //     elevation: 0,
              //     onPressed: () {},
              //     label: const Text("Cash On Delivery"),
              //     icon: const Icon(Icons.monetization_on_outlined),
              //   ),
              // ),
              Center(
                child: FloatingActionButton.extended(
                  elevation: 0,
                  onPressed: () async {
                    await initPaymentSheet();
                    try{
                      await Stripe.instance.presentPaymentSheet();

                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                        content: Text(
                          "Payment Done",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ));
                      paymentComplete = true;
                    }catch(e){
                      print("payment sheet failed");
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(
                        content: Text(
                          "Payment Failed",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.redAccent,
                      ));
                    }
                  },
                  label: const Text("Stripe Payment"),
                  icon: const Icon(Icons.monetization_on_outlined),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
