import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/views/chat_main_screen.dart';
import 'package:backcaps_logistics/views/chat_screen.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/send_parcel_screens/send_parcel_screen.dart';
import 'package:backcaps_logistics/views/track_customer_order.dart';
import 'package:backcaps_logistics/views/track_order_screen.dart';
import 'package:backcaps_logistics/widgets/custom_arrow_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../structure/Order.dart';
import '../../../structure/theme/color_scheme.dart';
import '../../../widgets/static_widgets.dart';
import '../../drawer_screen.dart';
import 'home_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0/**/;

  final screens = [];

  @override
  void initState() {
    super.initState();
    screens.add(buildHomeScreen(scaffoldKey: _scaffoldKey));
    screens.add(const SendParcelScreen());
    screens.add(const TrackCustomerOrder());
    screens.add(ChatMainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      body: screens[selectedIndex],
      bottomNavigationBar: buildNavigationBar(context),
    );
  }


  NavigationBar buildNavigationBar(context) {
    Color theme = MediaQuery
        .of(context)
        .platformBrightness == Brightness.light
        ? darkColorScheme.onPrimary
        : lightColorScheme.onPrimary;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => setState(() => selectedIndex = index),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
            icon: MediaQuery.of(context).platformBrightness == Brightness.light? SvgPicture.asset("assets/icons/package_outlined.svg"): SvgPicture.asset("assets/icons/package_outlined_dark.svg"),
            selectedIcon: MediaQuery.of(context).platformBrightness == Brightness.light? SvgPicture.asset("assets/icons/package_filled.svg") : SvgPicture.asset("assets/icons/package_filled_dark.svg"),
            label: "Send Parcel"),
        const NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: "Track Order"),
        const NavigationDestination(
          icon: Icon(Icons.chat_outlined),
          selectedIcon: Icon(Icons.chat),
          label: "Chat",
        ),
      ],
    );
  }
}

class SelectOrderRow extends StatelessWidget {
  const SelectOrderRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SendParcelScreen())),
            child: SelectOrderCard(
              title: "Premium Delivery",
              content: "Right from your doorstep.",
              svg: "assets/images/svg/package1.svg",
              id: "ID: 565 495",
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> SendParcelScreen())),
            child: SelectOrderCard(
                title: "Shared Delivery",
                content: "Get your delivery scheduled",
                id: "ID: 575 495",
                svg: "assets/images/svg/package1.svg",
                backgroundColor: blueishColor),
          ),
        ],
      ),
    );
  }
}

class SelectOrderCard extends StatelessWidget {
  final String title;
  final String content;
  final String id;
  final String svg;
  final Color backgroundColor;

  const SelectOrderCard({
    super.key,
    required this.title,
    required this.content,
    required this.id,
    required this.svg,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(color: backgroundColor.withOpacity(0.6)
              // color: Color(0xFFE49C6A).withOpacity(0.6),
              ),
          height: 250,
          width: 330,
        ),
        Positioned(
            top: 22,
            left: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: futura_bold.copyWith(
                    fontSize: 16,
                  ),
                ),
                Text(
                  content,
                  style: futura,
                ),
              ],
            )),
        Positioned(
          bottom: -35,
          right: -17,
          child: SvgPicture.asset(
            svg,
            height: 210,
            width: 200,
          ),
        ),
        Positioned(
          bottom: 22,
          left: 22,
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(30)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(id, style: futura_medium),
            ),
          ),
        ),
      ]),
    );
  }
}

class ShippingCard extends StatelessWidget {
  final Order order;
  const ShippingCard({super.key, required this.order});

  String formatDateTimeDifference(DateTime dateTime) {
    DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Duration difference = dateTime.difference(epoch);
    int days = difference.inDays;
    int hours = difference.inHours % 24;
    int minutes = difference.inMinutes % 60;

    List<String> parts = [];

    if (days > 0) parts.add('$days day${days > 1 ? 's' : ''}');
    if (hours > 0) parts.add('$hours hour${hours > 1 ? 's' : ''}');
    if (minutes > 0) parts.add('$minutes minute${minutes > 1 ? 's' : ''}');

    return parts.join(', ');
  }
  @override
  Widget build(BuildContext context) {
    // print(order.estimatedTime);
    String estimatedTime = formatDateTimeDifference(order.estimatedTime);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(kDefaultRounding)),
        child: Column(
          children: [
            _shippingNumberRow(context),
            RadialGradientDivider(),
            _shippingInfo(context,
                image: "package_send",
                section1: "Consignor",
                section2: "Time",
                sectionContent1: order.address.from.address,
                sectionContent2: estimatedTime
            ),
            const SizedBox(height: 20),
            _shippingInfo(context,
                image: "package_receive",
                section1: "Receiver",
                section2: "Status",
                sectionContent1: order.address.to.address,
                sectionContent2: order.status.name,
                haveStatusIcon: false),
          ],
        ),
      ),
    );
  }

  Widget _shippingNumberRow(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shippingSectionTitle(context, "Shipment Number"),
            Text("PD565 ${order.orderId}"),
          ],
        ),
        // CustomArrowButton(onPressed: () {}),
      ],
    );
  }

  Widget _shippingInfo(
    context, {
    required String image,
    required String section1,
    required String section2,
    required String sectionContent1,
    required String sectionContent2,
    bool haveStatusIcon = true,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(36)),
              width: 35,
              height: 35,
              child: Transform.scale(
                scale: 20 / 35,
                child: SvgPicture.asset(
                  "assets/images/svg/$image.svg",
                ),
              ),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shippingSectionTitle(context, section1),
                Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width / 2.5,
                      maxWidth: MediaQuery.of(context).size.width / 2.5),
                  child: Text(sectionContent1),
                )
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shippingSectionTitle(context, section2),
            Row(
              children: [
                haveStatusIcon
                    ? Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(36)),
                        width: 8,
                        height: 8,
                      )
                    : Container(),
                haveStatusIcon ? const SizedBox(width: 5) : Container(),
                Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width / 4,
                      maxWidth: MediaQuery.of(context).size.width / 4),
                  child: Text(sectionContent2),
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  Text shippingSectionTitle(context, String title) {
    return Text(
      title,
      style: poppins_bold.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onPrimaryContainer
              .withOpacity(0.8)),
    );
  }

  Widget _receiverAndStatus(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(36)),
              width: 35,
              height: 35,
              child: Transform.scale(
                scale: 20 / 35,
                child: SvgPicture.asset(
                  "assets/images/svg/package_receive.svg",
                ),
              ),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shippingSectionTitle(context, "Receiver"),
                Text(
                  "Bahria Town, Islamabad lahore",
                  style: poppins,
                )
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shippingSectionTitle(context, "Time"),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(36)),
                  width: 8,
                  height: 8,
                ),
                const SizedBox(width: 5),
                Text(
                  "1 day - 2 day",
                  style: poppins,
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
