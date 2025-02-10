import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:flutter/material.dart';

import '../../core/constants/constants.dart';
import '../static_widgets.dart';

class BidOrderCard extends StatefulWidget {
  final bool isSelected;
  final TextFieldController priceController;

  const BidOrderCard(
      {super.key, required this.isSelected, required this.priceController});

  @override
  State<BidOrderCard> createState() => _BidOrderCardState();
}

class _BidOrderCardState extends State<BidOrderCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(kDefaultRounding)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 10, 10, 0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(kDefaultRounding),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Text("Awan Traders",
                            style: roboto_bold.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onPrimary)),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildCustomFeatureIconRow(
                              title: "Rating",
                              content: "4.5/5",
                              icon: Icons.star,
                            ),
                            buildCustomFeatureIconRow(
                              title: "Offered Vehicle",
                              content: "Mini Truck",
                              icon: Icons.fire_truck,
                            ),
                            buildCustomFeatureIconRow(
                              title: "Category",
                              content: "Organization",
                              icon: Icons.category_outlined,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Image(
                            image:
                                AssetImage("assets/images/resources/mini.png")),
                      ),
                    ],
                  ),
                  RadialGradientDivider(),
                  !widget.isSelected
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildLongButton(context,
                                buttonColor: Colors.green,
                                filled: true,
                                title: "Confirm Bid",
                                onPressed: () {}),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
