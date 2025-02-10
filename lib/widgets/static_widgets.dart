import 'dart:ui';

import 'package:backcaps_logistics/views/FindJobScreen.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/find_orders_screen.dart';
import 'package:backcaps_logistics/views/track_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../core/constants/constants.dart';
import 'custom_feature_icon.dart';

Widget logisticLogo({double height = 200.0, context}) {
  return Hero(
    tag: "logistic-logo",
    child: Padding(
      padding: const EdgeInsets.all(30.0),
      child: Image(
        image: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? const AssetImage("assets/images/logos/dark_logo.png")
            : const AssetImage("assets/images/logos/logo.png"),
        height: height,
      ),
    ),
  );
}

Text buildHeadingText(String text) {
  return Text(
    text,
    style: const TextStyle(
        fontFamily: 'Futura', fontSize: 32, fontWeight: FontWeight.bold),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(title, style: roboto_bold),
    );
  }
}

class FuturisticSectionTitle extends StatelessWidget {
  final String title;
  const FuturisticSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title, style: poppins_bold),
    );
  }
}


class RadialGradientDivider extends StatelessWidget {
  final double radius;

  const RadialGradientDivider({super.key, this.radius = 220});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 0.5,
              child: Container(
                decoration: BoxDecoration(
                    gradient: RadialGradient(colors: [
                  Theme.of(context).colorScheme.onBackground,
                  Colors.transparent,
                ], radius: radius)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//Following is a button that is represented on Dashboard such as
//find job, Track Order etc.
Widget buildOptionButton(
  BuildContext context, {
  required String label,
  required String svg,
  required Color color,
  double svgWidth = 56,
  double svgHeight = 55,
  required Function() onPressed,
}) {
  return Ink(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(kDefaultRounding),
      color: color,
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(kDefaultRounding),
      child: SizedBox(
        width: 119,
        child: Align(
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 7),
                SvgPicture.asset(
                  svg,
                  height: svgHeight,
                  width: svgWidth,
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: 45,
                  width: 98,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 45,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 61,
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            // style: theme.textTheme.titleSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

//This is the vertical red line which is represented in source - destination
//screen
Column buildFromToDrawing(context) {
  return Column(
    children: [
      Text("From", style: poppins),
      Container(
        height: 6,
        width: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 1),
      Container(
        height: 59,
        width: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(height: 1),
      Container(
        height: 6,
        width: 6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      Text("To", style: poppins),
    ],
  );
}

Container CustomVerticalDivider(
    {
      double height = 17,
      double width = 1.5,
      required Color color,
    }
    ) {
  return Container(
    height: 17,
    width: 1.5,
    color: color,
  );
}

Widget buildDefaultPackageSize(
  BuildContext context, {
  required bool selected,
  required String title,
  required String size,
  required String packageSizeAsset,
  required Function() onPressed,
}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(kDefaultRounding)),
        child: Ink(
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(title,
                      style: poppins_bold.copyWith(
                          fontSize: 10,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onBackground)),
                  SvgPicture.asset(
                    "assets/images/svg/$packageSizeAsset.svg",
                    // height: 38,
                    width: 40,
                    fit: BoxFit.cover,
                  ),
                  Text(size,
                      style: poppins_bold.copyWith(
                          fontSize: 10,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onBackground))
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


Widget buildCustomFeatureIconRow({
  required String title,
  required String content,
  required IconData icon,
  Color? iconColor,
  Color? backgroundColor,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 5, 10, 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomFeatureIcon(
          icon: icon,
          iconColor: iconColor,
          backgroundColor: backgroundColor,
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: poppins_bold),
            Text(content, style: poppins),
          ],
        ),
      ],
    ),
  );
}

class CustomGrandText extends StatelessWidget {
  final String text;
  double? fontSize;
  Color? color;
  CustomGrandText({super.key, required this.text, this.fontSize, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: poppins_bold.copyWith(fontSize: fontSize?? 24, color: color),
    );
  }
}

Widget buildLongButton(context, {
  Color? buttonColor,
  required bool filled,
  int flex = 1,
  required String title,
  required Function()? onPressed,
}) {
  return Expanded(
    flex: flex,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: MaterialButton(
        disabledColor: Colors.grey,
        color: filled
            ? buttonColor ?? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        elevation: 0,
        height: 47,
        textColor: filled
            ? Theme.of(context).colorScheme.onPrimary
            : buttonColor ?? Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: onPressed!=null? buttonColor ?? Theme.of(context).colorScheme.primary : Colors.grey),
            borderRadius: BorderRadius.circular(36)),
        onPressed: onPressed,
        child: Text(
          title,
          style: poppins_bold,
        ),
      ),
    ),
  );
}

Widget loadingBackgroundBlur(bool isLoading){
  if (isLoading)
    return Positioned.fill(
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 5.0,
              sigmaY: 5.0,
            ),
            child: Container(),
          ),
        ));
  else return Container();
}
Widget loadingIndicator(BuildContext context, bool isLoading){
  if(isLoading)
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(kDefaultRounding),
        ),
        padding: const EdgeInsets.all(40),
        child: const CircularProgressIndicator(),
      ),
    );
  else{
    return Container();
  }

}

class BuildOptionRow extends StatelessWidget {
  final String role;
  final String? userId;
  const BuildOptionRow({Key? key, required this.role, this.userId})
      : super(
    key: key,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildOptionButton(context,
            label: role == "Role.Customer" ? "Send Package" : "Find Orders",
            svg: "assets/images/svg/package2.svg",
            color: Theme.of(context).colorScheme.primaryContainer,
            onPressed: () {
              if(role == "Role.Driver"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => FindOrdersScreen()));
              }
            },
          ),
          buildOptionButton(context,
            label: role == "Role.Driver"? "Assignments" : "Track Order",
            svg: "assets/images/svg/track_order.svg",
            color: Theme.of(context).colorScheme.tertiaryContainer,
            onPressed: () {
              if(role == "Role.Driver"){
                Navigator.push(context, MaterialPageRoute(builder: (context) => TrackOrderScreen()));
              }
            },
          ),
          buildOptionButton(
            context,
            label: "Find Job",
            svg: "assets/images/svg/find_job.svg",
            color: blueishColor,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> FindJobScreen()));
            },
          ),
        ],
      ),
    );
  }
}


class OutlinedContainerText extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onPressed;

  const OutlinedContainerText({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.5)),
                borderRadius: BorderRadius.circular(6)),
            child: ListTile(
              leading: Icon(icon),
              title: Text(title),
              onTap: onPressed,
            ),
          ),
        ),
      ],
    );
  }
}

