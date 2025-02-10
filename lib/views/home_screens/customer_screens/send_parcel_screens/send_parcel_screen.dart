import 'dart:async';

import 'package:backcaps_logistics/core/controllers/organization_controller.dart';
import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/structure/enums/OrderStatus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

// import 'package:html/dom.dart' as dom;
import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/structure/enums/PackageSize.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/customer_home_screen.dart';
import 'package:backcaps_logistics/views/source_destination_screen.dart';
import 'package:backcaps_logistics/widgets/custom_outlined_text_field.dart';
import 'package:backcaps_logistics/widgets/send_parcel/bid_order_card.dart';
import 'package:backcaps_logistics/widgets/send_parcel/special_delivery_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:backcaps_logistics/structure/Address.dart' as structureAddress;
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../core/controllers/order_controller.dart';
import '../../../../core/utils/text_handler.dart';
import '../../../../main.dart';
import '../../../../structure/BoxContainer.dart';
import '../../../../structure/Order.dart';
import '../../../../structure/Package.dart';
import '../../../../widgets/custom_price_section.dart';
import '../../../../widgets/static_widgets.dart';
import '../../../supporting/redirect_user.dart';
import '../../driver_screens/register_vehicle_screen.dart';
import '../../owner_screens/OrganizationCard.dart';
import 'components/data/choice_chips_list.dart';
import 'components/data/filter_chips_list.dart';
import '../../../../../structure/theme/color_scheme.dart';
import 'components/structure/FilterChipData.dart';

part 'order_processing.dart';

class SendParcelScreen extends StatefulWidget {
  const SendParcelScreen({super.key});

  @override
  State<SendParcelScreen> createState() => _SendParcelScreenState();
}

class _SendParcelScreenState extends State<SendParcelScreen> {
  /*----------------------
  * ---AppBar variables----
  * -------------------------*/
  int numberOfPages = 4;
  double defaultToolBarHeight = 70.0;
  int activePage = 0;

  /*----First page variables ------*/
  bool packageSizeState = true; //true = default & false = manual
  PackageSize packageSize = PackageSize.s; // default small size
  int packages = 1;
  int weightPerPackage = 1;
  final _formKey = GlobalKey<FormState>();
  final _fromField = TextFieldController();
  final _toField = TextFieldController();
  final _containerL = TextFieldController();
  final _containerW = TextFieldController();
  final _containerH = TextFieldController();
  structureAddress.Address? toFromAddress;
  double totalDistance = 0.0;
  double totalDuration = 0.0;
  var fuelPrice = 288.49;

  /*-----Second page variables --------*/
  var chips = ChoiceChips.chips;
  var filterChips = FilterChips.chips;
  List<String> typeList = [];
  late String loadingType;

  bool isSearching = false;
  bool isLoading = false;
  late Order order;
  int price = 9050;
  bool isSharedDelivery = false;
  final priceController = TextFieldController();
  // String _fuelPrice = 'Fetching...';

  @override
  void initState() {
    super.initState();
    priceController.controller.text = "$price";
    _containerL.controller.text = "2";
    _containerW.controller.text = "2";
    _containerH.controller.text = "2";
    // fetchFuelPrice();
  }

  // Future<void> fetchFuelPrice() async {
  //   try {
  //     // Make HTTP GET request
  //     final response = await http
  //         .get(Uri.parse('https://tribune.com.pk/fuel-prices-in-pakistan'));
  //
  //     if (response.statusCode == 200) {
  //       // Parse HTML content
  //       final document = parser.parse(response.body);
  //
  //       // Extract fuel price
  //       final fuelPriceElement = document.querySelector('#nav-home');
  //       print(fuelPriceElement?.text);
  //       final fuelPrice = fuelPriceElement?.toString();
  //
  //       setState(() {
  //         _fuelPrice = fuelPrice ?? 'Price not found';
  //       });
  //     } else {
  //       setState(() {
  //         _fuelPrice = 'Failed to fetch data';
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       _fuelPrice = 'Error: $e';
  //     });
  //   }
  // }

  Widget buildSendParcelAppBar(BuildContext context) {
    return SliverAppBar(
      // centerTitle: true,
      automaticallyImplyLeading: false,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: Container(),
      leadingWidth: 0.0,
      toolbarHeight: defaultToolBarHeight,
      flexibleSpace: FlexibleSpaceBar(
        title: Container(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildRestartButton(context),
                buildTitle(context, "Send Parcel"),
                buildCloseButton(context)
              ],
            ),
          ),
        ),
        background: _buildTabFill(context),
      ),
    );
  }

  IconButton buildCloseButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.close,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      onPressed: () {
        Utils.showConfirmationDialogue(context,
            title: "Cancel order process",
            content: "Are you sure you want to cancel the order process.",
            confirmText: "Yes", onConfirm: () async {
          await checkAndDeleteOrder(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const RedirectUser()));
        }, cancelText: "No");
      },
    );
  }

  IconButton buildRestartButton(BuildContext context) {
    return IconButton(
      icon: const Icon(
        Icons.restart_alt_outlined,
      ),
      color: Theme.of(context).colorScheme.onPrimary,
      disabledColor: Theme.of(context).colorScheme.onPrimary.withOpacity(.3),
      onPressed: activePage > 0
          ? () async {
              await checkAndDeleteOrder(context);
              setState(() {
                activePage = 0;
              });
            }
          : null,
    );
  }

  Future<void> checkAndDeleteOrder(BuildContext context) async {
    if(activePage >= 3){
      setState(() => isLoading = true);
      print(order.orderId);
      await Provider.of<OrderControllerProvider>(context, listen: false).deleteOrder(order.orderId);
      setState(() => isLoading = false);
    }
  }

  Text buildTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
          fontFamily: roboto.fontFamily,
          color: Theme.of(context).colorScheme.onPrimary),
    );
  }

  Container _buildTabFill(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ...List.generate(
              numberOfPages,
              (index) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: index <= activePage
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.inversePrimary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(kDefaultRounding),
                    ),
                    height: 6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Stack(
          children: [
            Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    buildSendParcelAppBar(context),
                    SliverToBoxAdapter(
                      child: activePage == 0
                          ? buildSendParcelPageOne(context)
                          : activePage == 1
                              ? buildGoodsTypePageTwo(context)
                              : activePage == 2
                                  ? buildAvailableVehiclePageThree(context)
                                  // : activePage == 3
                                  //     ? buildFareCalculationPageFour(context)
                                  : activePage >= 3
                                      ? buildSelectCourierPageFive(context)
                                      : Container(),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: activePage == 0
                      ? Row(
                          children: [
                            buildLongButton(context, filled: true, title: "Next",
                                onPressed: () {
                              if (!packageSizeState) {
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                              }
                              if (toFromAddress == null) {
                                Utils.showAlertPopup(context, "Something went wrong",
                                    "Source and destination path is required.");
                                return;
                              }
                              setState(() {
                                activePage += 1;
                              });
                            })
                          ],
                        )
                      : activePage == 1
                          ? buildBackAndNext()
                          : activePage == 2
                              ? buildBackAndNext()
                              // : activePage == 3
                              //     ? buildBottomPriceTagAndButtons(context)
                              : activePage >= 3
                                  ? buildBottomPriceTagAndButtons(context)
                                  : Container(),
                ),
              ],
            ),
            loadingBackgroundBlur(isLoading),
            loadingIndicator(context, isLoading),
          ],
        ),
      ),
    );
  }

  Material buildBottomPriceTagAndButtons(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(kDefaultRounding),
      elevation: 20,
      color: Theme.of(context).colorScheme.background,
      child: SizedBox(
        height: price != 0 ? 145 : 110,
        child: Column(
          children: [
            const Gap(20),
            price != 0
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomGrandText(text: "Total Price"),
                      CustomPriceSection(
                        controller: priceController,
                        onMinusPressed: () {
                          if (price != 0) {
                            setState(() {
                              price -= 1;
                              priceController.controller.text = "$price";
                            });
                          }
                        },
                        onPlusPressed: () {
                          // TODO if(max price)
                          setState(() {
                            price += 1;
                            priceController.controller.text = "$price";
                          });
                        },
                      ),
                      // buildBackAndNext(),
                    ],
                  )
                : const Text("Price is not available in smart selection."),
            buildBackAndNext(),
          ],
        ),
      ),
    );
  }

  Widget buildSelectCourierPageFive(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildLongButton(context,
                  filled: !isSharedDelivery,
                  title: "Special", onPressed: () async {
                if (isSharedDelivery != false) {
                  setState(() {
                    isSharedDelivery = false;
                  });
                  await Provider.of<OrderControllerProvider>(context,
                          listen: false)
                      .updateSharedDelivery(order.orderId, isSharedDelivery);
                }
              }),
              buildLongButton(context,
                  filled: isSharedDelivery,
                  title: "Shared", onPressed: () async {
                if (isSharedDelivery != true) {
                  setState(() {
                    isSharedDelivery = true;
                  });
                  await Provider.of<OrderControllerProvider>(context,
                          listen: false)
                      .updateSharedDelivery(order.orderId, isSharedDelivery);
                }
              }),
            ],
          ),
          CustomGrandText(
              text: isSharedDelivery
                  ? "Shared Courier Services"
                  : "Premium Delivery"),
          const SizedBox(height: 5),
          !isSharedDelivery
              ? Consumer<OrderControllerProvider>(
            builder: (context, orderControllerProvider, _){
              return FutureBuilder(
                future: orderControllerProvider.getOfferedOrders(),
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    Utils.showAlertPopup(context, "Something went wrong", ("We can't fetch the data from Offer database please contact developer"));
                    return Container();
                  }
                  else if(snapshot.hasData){
                    final orders = snapshot.data;
                    List<Order> specificOrders = [];
                    for(var offerOrder in orders!){
                      if(offerOrder.orderId.split("_")[0] == order.orderId){
                        specificOrders.add(offerOrder);
                      }
                    }
                    if(specificOrders.isEmpty){
                      return SizedBox(height: 250, child: Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LoadingAnimationWidget.staggeredDotsWave(color: Theme.of(context).colorScheme.primary, size: 100),
                          const Text("Looking for offers...")
                        ],
                      )));
                    }
                    return Column(
                      children: [
                        ...List.generate(specificOrders.length, (index){
                      return SpecialDeliveryCard(order: specificOrders[index]);
                    })
                      ],
                    );
                    // print(orders![0].toJson());
                    // return Container();
                    // return NearbyCard(order: orders![0]);
                  }
                  else{
                    return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(),),);
                  }
                },
              );
            },
          )
              : Consumer<OrganizationControllerProvider>(builder: (context, organizationControllerProvider, _){
                return FutureBuilder(future: organizationControllerProvider.getOrganizations(), builder: (context, snapshot){
                  if(snapshot.hasError){
                    Fluttertoast.showToast(msg: "Error displaying organizations, contact developer.");
                    return Container();
                  }
                  else if(snapshot.hasData){
                    final organizations = snapshot.data;
                    return Column(
                      children: [
                        ...List.generate(organizations.length, (index){
                          final newOrder = createOrder("Smart Selection");
                          newOrder.orderId = order.orderId;
                          return OrganizationCard(organization: organizations[index], isOrder: true, order: newOrder);
                        }),

                      ],
                    );
                  }else{
                    return const SizedBox(
                      height: 250,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                });
          },),
          // : BidOrderCard(isSelected: true, priceController: priceController),
          const Gap(55),
        ],
      ),
    );
  }

  Widget buildFareCalculationPageFour(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomGrandText(text: "Properties"),
              const SizedBox(height: 5),
              _buildPropertiesTitle(context),
              const SizedBox(height: 5),
              Text(
                "The fare is calculated based on real-time data. In case of any issue you can report to ",
                style: poppins,
                textAlign: TextAlign.justify,
              ),
              Text("temporary@gmail.com", style: poppins_bold),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildPropertiesTitle(context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(kDefaultRounding)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
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
                    Text("Type",
                        style: roboto_bold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    CustomVerticalDivider(
                        color: Theme.of(context).colorScheme.onPrimary),
                    Text("Per Unit",
                        style: roboto_bold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    CustomVerticalDivider(
                        color: Theme.of(context).colorScheme.onPrimary),
                    Text("Quantity",
                        style: roboto_bold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary)),
                    CustomVerticalDivider(
                        color: Theme.of(context).colorScheme.onPrimary),
                    Text("RS.Price",
                        style: roboto_bold.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary))
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {0: FractionColumnWidth(.35)},
                children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text("Fuel"),
                    ),
                    const Text("N/A"),
                    const Text("N/A"),
                    const Text("N/A"),
                  ]),
                  tableDivider(),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text("Weight (kg)"),
                    ),
                    const Text("N/A"),
                    const Text("N/A"),
                    const Text("N/A"),
                  ]),
                  tableDivider(),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text("Package/s"),
                    ),
                    const Text("N/A"),
                    const Text("N/A"),
                    const Text("N/A"),
                  ]),
                  tableDivider(),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text("Distance (km)"),
                    ),
                    const Text("N/A"),
                    const Text("N/A"),
                    const Text("N/A"),
                  ])
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow tableDivider() {
    return TableRow(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 1.0,
          ),
        ),
      ),
      children: [
        TableCell(
          child: SizedBox.shrink(), // Empty TableCell
        ),
        TableCell(
          child: SizedBox.shrink(), // Empty TableCell
        ),
        TableCell(
          child: SizedBox.shrink(), // Empty TableCell
        ),
        TableCell(
          child: SizedBox.shrink(), // Empty TableCell
        ),
      ],
    );
  }

  Widget buildGoodsTypePageTwo(context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomGrandText(text: "Good Details"),
          const SectionTitle(title: "Type"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filterChips
                  .map((chip) => ChoiceChip(
                        label: Text(chip.label),
                        selected: chip.isSelected,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kDefaultRounding),
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onSelected: (isSelected) {
                          setState(() {
                            if (chip.label == 'Other' && isSelected) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Enter type name'),
                                  content: TextField(
                                    autofocus: true,
                                    onChanged: (value) {
                                      setState(() {
                                        chip.label = value;
                                      });
                                    },
                                  ),
                                  actions: [
                                    MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          filterChips.removeLast();
                                          filterChips.add(FilterChipData(
                                              label: chip.label,
                                              isSelected: true));
                                          filterChips.add(FilterChipData(
                                              label: 'Other',
                                              isSelected: false));
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Add'),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              // Update the selection of other chips
                              filterChips = filterChips.map((otherChip) {
                                return chip == otherChip &&
                                        chip.label != 'Other'
                                    ? otherChip.copy(isSelected: isSelected)
                                    : otherChip;
                              }).toList();
                            }
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
          const SectionTitle(title: "Loading Type"),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((chip) => ChoiceChip(
                        label: Text(chip.label),
                        selected: chip.isSelected,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(kDefaultRounding),
                        ),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onSelected: (isSelected) => setState(() {
                          chips = chips.map((oldChips) {
                            final newChip = oldChips.copy(isSelected: false);
                            return chip == newChip
                                ? newChip.copy(isSelected: isSelected)
                                : newChip;
                          }).toList();
                        }),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBackAndNext() {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Row(
        children: [
          buildLongButton(context, flex: 1, filled: false, title: "Back",
              onPressed: () async {
            await checkAndDeleteOrder(context);
            setState(() {
              activePage -= 1;
            });
          }),
          activePage == 2
              ? Container(
                  height: 47,
                )
              : buildLongButton(
                  context,
                  flex: 3,
                  filled: true,
                  title: activePage == 3 ? "Search" : "Next",
                  onPressed: !isSearching
                      ? () async {
                          if (activePage == 1) {
                            typeList = [];
                            filterChips.forEach((chip) {
                              if (chip.isSelected) typeList.add(chip.label);
                            });
                            for (var chip in chips) {
                              if (chip.isSelected) {
                                loadingType = chip.label;
                              }
                            }
                            if (typeList.isEmpty) {
                              Utils.showAlertPopup(
                                  context,
                                  "Something went wrong",
                                  "Please select at least one type.");
                              return;
                            }
                          }
                          if (activePage != 3) {
                            setState(() {
                              activePage += 1;
                            });
                          } else {
                              Provider.of<OrderControllerProvider>(context, listen: false).deleteOrder(order.orderId);
                              setState(() => isLoading = true);
                              price = int.parse(priceController.controller.text);
                              order = createOrder(order.vehicleCategory);
                              final user = await Provider.of<UserControllerProvider>(context, listen: false).getUser();
                              order.customerName = user.name;
                              order.customerImage = user.imageUrl;
                              order.orderId = DateTime.now().millisecondsSinceEpoch.toString();
                              await Provider.of<OrderControllerProvider>(context, listen: false)
                                  .createOrder(order);
                              setState(() => isLoading = false);
                            setState(() {
                              isSearching = !isSearching;
                            });
                            Timer.periodic(Duration(seconds: 10), (timer) {
                              setState(() {
                                isSearching = !isSearching;
                              });
                            });
                          }
                        }
                      : null,
                ),
        ],
      ),
    );
  }

  Future<void> sourceDestinationFieldOnPressed() async {
    toFromAddress = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SourceDestinationScreen()));
    if (toFromAddress != null) {
      setState(() {
        totalDistance = toFromAddress!.timeDistanceMatrix.distances[0][1];
        totalDuration = toFromAddress!.timeDistanceMatrix.durations[0][1];
        print(totalDuration);
        print(totalDistance);
        _fromField.controller.text = toFromAddress!.from.address;
        _toField.controller.text = toFromAddress!.to.address;
      });
    }
  }

  Widget buildSendParcelPageOne(context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomGrandText(text: "Enter parcel’s details"),
            const Gap(10),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: buildFromToDrawing(context),
                ),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: OutlinedContainerText(
                          icon: Icons.gps_fixed_outlined,
                          title: _fromField.controller.text == ""
                              ? "Select source"
                              : _fromField.controller.text,
                          onPressed: sourceDestinationFieldOnPressed,
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: OutlinedContainerText(
                            icon: Icons.pin_drop_outlined,
                            title: _toField.controller.text == ""
                                ? "Select destination"
                                : _toField.controller.text,
                            onPressed: sourceDestinationFieldOnPressed,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            _buildTabSwitcher(),
            const SectionTitle(title: "Package Size"),
            packageSizeState
                ? _buildDefaultPackageSize(context)
                : _buildManualPackageSize(context),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: "Packages"),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Ink(
                          child: InkWell(
                            onTap: () {
                              showCupertinoModalPopup<void>(
                                context: context,
                                builder: (BuildContext context) => Container(
                                  height: 216,
                                  padding: const EdgeInsets.only(top: 6.0),
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  color: CupertinoColors.systemBackground
                                      .resolveFrom(context),
                                  child: SafeArea(
                                    top: false,
                                    child: CupertinoPicker(
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32.0,
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem: 0,
                                      ),
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                        setState(() {
                                          packages = selectedItem + 1;
                                        });
                                      },
                                      children: List<Widget>.generate(100,
                                          (int index) {
                                        return Center(
                                            child: Text("${index + 1}"));
                                      }),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(kDefaultRounding),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 5,
                                            child: Text(
                                              "$packages",
                                              style: roboto_bold,
                                            )),
                                      ],
                                    ),
                                    Text(
                                      "Max 100",
                                      style: roboto_bold.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground
                                              .withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle(title: "Weight per package"),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Ink(
                          child: InkWell(
                            onTap: () {
                              showCupertinoModalPopup<void>(
                                context: context,
                                builder: (BuildContext context) => Container(
                                  height: 216,
                                  padding: const EdgeInsets.only(top: 6.0),
                                  margin: EdgeInsets.only(
                                    bottom: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom,
                                  ),
                                  color: CupertinoColors.systemBackground
                                      .resolveFrom(context),
                                  child: SafeArea(
                                    top: false,
                                    child: CupertinoPicker(
                                      magnification: 1.22,
                                      squeeze: 1.2,
                                      useMagnifier: true,
                                      itemExtent: 32.0,
                                      scrollController:
                                          FixedExtentScrollController(
                                        initialItem: 0,
                                      ),
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                        setState(() {
                                          weightPerPackage = selectedItem + 1;
                                        });
                                      },
                                      children: List<Widget>.generate(200,
                                          (int index) {
                                        return Center(
                                            child: Text("${index + 1}"));
                                      }),
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius:
                                    BorderRadius.circular(kDefaultRounding),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          "$weightPerPackage",
                                          style: roboto_bold,
                                        )),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Icon(Icons.keyboard_arrow_down),
                                              Text(
                                                "KG",
                                                style: roboto_bold.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground
                                                        .withOpacity(0.5)),
                                              ),
                                              // Icon(Icons.keyboard_arrow_down),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      "Max weight 200kg",
                                      style: roboto_bold.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground
                                              .withOpacity(0.5)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Gap(55),
          ],
        ),
      ),
    );
  }

  SizedBox _buildManualPackageSize(context) {
    return SizedBox(
      height: MediaQuery.of(context).size.width / 1.5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SvgPicture.asset(
                "assets/images/svg/manual_package_size.svg",
                height: MediaQuery.of(context).size.width / 3,
              ),
              const Gap(20),
              Row(
                children: [
                  Expanded(
                    child: CustomOutlinedTextField(
                      context,
                      textFieldController: _containerL,
                      icon: null,
                      type: TextInputType.number,
                      label: "Length",
                      placeholder: "ft",
                      suffixIcon: null,
                      validator: validatorFunction("field required"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.close,
                      size: 30,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(.5)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomOutlinedTextField(
                      context,
                      type: TextInputType.number,
                      textFieldController: _containerW,
                      label: "Width",
                      placeholder: "ft",
                      suffixIcon: null,
                      validator: validatorFunction("field required"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.close,
                      size: 30,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(.5)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomOutlinedTextField(
                      context,
                      type: TextInputType.number,
                      textFieldController: _containerH,
                      label: "Height",
                      placeholder: "ft",
                      suffixIcon: null,
                      validator: validatorFunction("field required"),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildDefaultPackageSize(context) {
    return Row(
      children: [
        buildDefaultPackageSize(context,
            selected: packageSize == PackageSize.s ? true : false,
            title: "Small",
            size: "<2ft",
            packageSizeAsset: "small_package", onPressed: () {
          if (packageSize != PackageSize.s) {
            setState(() {
              _containerL.controller.text = "2";
              _containerW.controller.text = "2";
              _containerH.controller.text = "2";
              packageSize = PackageSize.s;
            });
          }
        }),
        buildDefaultPackageSize(context,
            selected: packageSize == PackageSize.m ? true : false,
            title: "Medium",
            size: "3 - 4ft",
            packageSizeAsset: "package_size", onPressed: () {
          if (packageSize != PackageSize.m) {
            setState(() {
              _containerL.controller.text = "4";
              _containerW.controller.text = "4";
              _containerH.controller.text = "4";
              packageSize = PackageSize.m;
            });
          }
        }),
        buildDefaultPackageSize(context,
            selected: packageSize == PackageSize.l ? true : false,
            title: "Large",
            size: "4 - 5ft",
            packageSizeAsset: "package_size", onPressed: () {
          if (packageSize != PackageSize.l) {
            setState(() {
              _containerL.controller.text = "5";
              _containerW.controller.text = "5";
              _containerH.controller.text = "5";
              packageSize = PackageSize.l;
            });
          }
        }),
        buildDefaultPackageSize(context,
            selected: packageSize == PackageSize.xl ? true : false,
            title: "Extra Large",
            size: "5ft>",
            packageSizeAsset: "package_size", onPressed: () {
          if (packageSize != PackageSize.xl) {
            setState(() {
              _containerL.controller.text = "6";
              _containerW.controller.text = "6";
              _containerH.controller.text = "6";
              packageSize = PackageSize.xl;
            });
          }
        }),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        buildLongButton(context, filled: packageSizeState, title: "Default",
            onPressed: () {
          if (!packageSizeState) {
            setState(() {
              packageSize = PackageSize.s;
              _containerL.controller.text = "2";
              _containerW.controller.text = "2";
              _containerH.controller.text = "2";
              packageSizeState = true;
            });
          }
        }),
        buildLongButton(context, filled: !packageSizeState, title: "Manual",
            onPressed: () {
          if (packageSizeState) {
            setState(() {
              _containerL.controller.text = "";
              _containerW.controller.text = "";
              _containerH.controller.text = "";
              packageSizeState = false;
            });
          }
        }),
      ],
    );
  }

  Widget buildAvailableVehiclePageThree(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomGrandText(text: "Available Vehicles"),
            Text(
              "If you are not sure which option to select just click on smart selection.",
              style: poppins,
            ),
            const SizedBox(height: 5),
            GridView.count(
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: EdgeInsets.zero,
              primary: false,
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                buildVehicleBox(
                  context,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  title: "Smart Selection",
                  assetImage: "vehicles",
                  onPressed: () {
                    // Sample calculation for Smart Selection price
                    const averageCapacity = 1 / 10; // Average vehicle capacity
                    const averageIdleConsumption = 3.0; // Average idle fuel consumption
                    int baseCharge = 1000; // Base charge for the service
                    double distanceFactor = (averageCapacity * totalDistance) * fuelPrice;
                    double timeFactor = (averageIdleConsumption * totalDuration / 3600) * fuelPrice;
                    int packageFactor = (packages * 50); // Example charge per package

                    price = (baseCharge + distanceFactor + timeFactor + packageFactor).toInt();
                    if (totalDistance < 25.0) {
                      price += 2000;
                    }
                    onAvailableVehicleSelect("Smart Selection");
                  },
                ),
                buildVehicleBox(
                  context,
                  color: darkBlueishColor,
                  title: "Pickup",
                  assetImage: "pickup",
                  onPressed: () {
                    const pickupCapacity = 1 / 13; // 1 divide by max millage
                    const pickupIdleConsumption = 2.54;
                    price = ((pickupCapacity * totalDistance) * fuelPrice +
                        (pickupIdleConsumption * totalDuration / 3600) * fuelPrice)
                        .toInt();
                    if (totalDistance < 25.0) {
                      //Set-up charges
                      price += 2000;
                    }
                    onAvailableVehicleSelect("Pickup");
                  },
                ),
                buildVehicleBox(
                  context,
                  color: yellowishColor,
                  title: "Mini Truck",
                  assetImage: "mini",
                  onPressed: () {
                    const miniTruckCapacity = 1 / 10; // 1 divide by max millage
                    const miniTruckIdleConsumption = 3.066;
                    price = ((miniTruckCapacity * totalDistance) * fuelPrice +
                        (miniTruckIdleConsumption * totalDuration / 3600) * fuelPrice)
                        .toInt();
                    if (totalDistance < 25.0) {
                      price += 4000;
                    }
                    onAvailableVehicleSelect("Mini Truck");
                  },
                ),
                buildVehicleBox(
                  context,
                  color: greenishColor,
                  title: "2-Axle Truck",
                  assetImage: "truck2",
                  onPressed: () {
                    const twoAxleTruckCapacity = 1 / 8; // 1 divide by max millage
                    const twoAxleTruckIdleConsumption = 3.79;
                    price = ((twoAxleTruckCapacity * totalDistance) * fuelPrice +
                        (twoAxleTruckIdleConsumption * totalDuration / 3600) * fuelPrice)
                        .toInt();
                    if (totalDistance < 25.0) {
                      price += 6000;
                    }
                    onAvailableVehicleSelect("2-Axle Truck");
                  },
                ),
                buildVehicleBox(
                  context,
                  color: purplishColor,
                  title: "Large Truck",
                  assetImage: "large2",
                  onPressed: () {
                    const twoAxleTruckCapacity = 1 / 5; // 1 divide by max millage
                    const twoAxleTruckIdleConsumption = 5.68;
                    price = ((twoAxleTruckCapacity * totalDistance) * fuelPrice +
                        (twoAxleTruckIdleConsumption * totalDuration / 3600) * fuelPrice)
                        .toInt();
                    if (totalDistance < 25.0) {
                      price += 8000;
                    }
                    onAvailableVehicleSelect("Large Truck");
                  },
                ),
              ],
            ),
            const Gap(50),
          ],
        ),
      ),
    );
  }


  onAvailableVehicleSelect(String type) async {
    priceController.controller.text = "$price";
    setState(() => isLoading = true);
    order = createOrder(type);
    final user = await Provider.of<UserControllerProvider>(context, listen: false).getUser();
    order.customerName = user.name;
    order.customerImage = user.imageUrl;
    order.orderId = DateTime.now().millisecondsSinceEpoch.toString();
    await Provider.of<OrderControllerProvider>(context, listen: false)
        .createOrder(order);
    setState(() => isLoading = false);
    setState(() {
      activePage += 1;
      print(activePage);
    });
  }

  Order createOrder(String vehicleCategory) {
    double seconds = toFromAddress!.timeDistanceMatrix.durations.first.last;
    int milliseconds = (seconds * 1000).toInt();
    DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    DateTime estimatedTime = epoch.add(Duration(milliseconds: milliseconds));
    return Order(
      price: price,
      address: toFromAddress!,
      estimatedTime: estimatedTime, //toFromAddress!.timeDistanceMatrix.durations.first.first
      orderTime: DateTime.now(),
      status: OrderStatus.Pending,
      vehicleId: "NULL",
      vehicleCategory: vehicleCategory,
      driverId: "NULL",
      organizationId: "NULL",
      customerId: "NULL",
      customerName: "NULL",
      customerImage: "NULL",
      numberOfPackage: packages,
      package: Package(
          //properties
          BoxContainer(
            height: double.parse(_containerH.controller.text),
            length: double.parse(_containerL.controller.text),
            width: double.parse(_containerW.controller.text),
            maxWeight: weightPerPackage.toDouble(),
          ),
          //package type
          typeList,
          //Loading Type
          loadingType),
      sharedDelivery: isSharedDelivery,
    );
  }

  Widget buildVehicleBox(
    BuildContext context, {
    required Color color,
    required String title,
    required String assetImage,
    required Function() onPressed,
  }) {
    return Ink(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(kDefaultRounding)),
      child: InkWell(
        borderRadius: BorderRadius.circular(kDefaultRounding),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 18, 5, 7),
          child: Column(
            children: [
              Text(title, style: poppins_bold),
              Expanded(
                  child: Image(
                      image: AssetImage(
                          "assets/images/resources/$assetImage.png"))),
            ],
          ),
        ),
      ),
    );
  }
}
