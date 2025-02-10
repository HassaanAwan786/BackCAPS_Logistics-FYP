import 'dart:async';
import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/components/vehicle_card.dart';
import 'package:backcaps_logistics/views/track_order_screen.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/controllers/order_controller.dart';
import '../../../structure/Order.dart';
import '../../../structure/enums/OrderStatus.dart';
import '../../../widgets/custom_arrow_button.dart';
import '../../../widgets/custom_price_section.dart';
import '../../supporting/redirect_user.dart';

class FindOrdersScreen extends StatefulWidget {
  const FindOrdersScreen({super.key});

  @override
  State<FindOrdersScreen> createState() => _FindOrdersScreenState();
}

class _FindOrdersScreenState extends State<FindOrdersScreen> {
  int selectedVehicle = 0;
  late String userId;
  bool firstRun = true;

  @override
  void initState() {
    super.initState();
    userId = Provider.of<UserControllerProvider>(context,listen: false).user.userId;
    checkUnDeliveredOrders();
  }

  Future<void> checkUnDeliveredOrders() async {
    final orderPending = await Provider.of<OrderControllerProvider>(context, listen: false).havePendingOrders();
    if(orderPending){
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Oops!!! Already pending orders"),
              content: const Text(
                  "Please complete the previous orders first."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TrackOrderScreen())),
                  child: const Text("Track Order"),
                ),
              ],
            );
          });
    }
  }

  @override
  void dispose() {
    try {
      Provider.of<OrderControllerProvider>(context, listen: false)
          .acceptedOrder = "NULL";
    } catch (e) {
      print("Exception of calling dispose early");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Orders"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RedirectUser()));
          },
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: Consumer<VehicleControllerProvider>(
            builder: (context, vehicleControllerProvider, _) {
              return FutureBuilder(
                  future: vehicleControllerProvider.getAllVehicles(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      Utils.showAlertPopup(context, "Something went wrong",
                          "Could not fetch vehicles record from database. Please contact developer.");
                      return Container();
                    } else if (snapshot.hasData) {
                      final vehicles = snapshot.data;
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 250,
                                    child: PageView(
                                      onPageChanged: (index) {
                                        setState(() {
                                          selectedVehicle = index;
                                        });
                                      },
                                      children: [
                                        ...List.generate(vehicles!.length, (index) {
                                          // if(!vehicles[index].isAvailable) return Container();
                                          return Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child:
                                            VehicleCard(vehicle: vehicles[index], selectable: false,),
                                          );
                                        })
                                      ],
                                    ),
                                  ),
                                  PageViewDotIndicator(
                                    currentItem: selectedVehicle,
                                    count: vehicles.length,
                                    unselectedColor:
                                    Theme.of(context).colorScheme.surfaceVariant,
                                    selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                    size: const Size(12, 12),
                                    unselectedSize: const Size(8, 8),
                                  ),
                                  const RadialGradientDivider(),
                                  Consumer<OrderControllerProvider>(
                                    builder: (context, orderControllerProvider, _) {
                                      return FutureBuilder(
                                          future: orderControllerProvider
                                              .getOfferedOrders(),
                                          builder: (context, snapshot) {
                                            if(snapshot.hasError){
                                              Fluttertoast.showToast(msg: "Error fetching offers from database.");
                                              return Container();
                                            } else if(snapshot.hasData){
                                              final offers = snapshot.data;
                                              final myOffers = [];
                                              for(var offer in offers!){
                                                if(offer.orderId.split("_")[1] == userId){
                                                  myOffers.add(offer);
                                                }
                                              }
                                              return Column(
                                                children: [
                                                  ...List.generate(
                                                      myOffers.length,
                                                          (index) => Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 8.0),
                                                        child: OrderCard(
                                                          order: myOffers[
                                                          index],
                                                          showPrice: true,
                                                          userId: userId,
                                                          isOffer: true,
                                                        ),
                                                      ))
                                                ],
                                              );
                                            } else {
                                              return Container();
                                            }
                                          });
                                    },
                                  ),
                                  Consumer<OrderControllerProvider>(
                                    builder: (context, orderControllerProvider, _) {
                                      return FutureBuilder(
                                          future: orderControllerProvider.getOrders(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasError) {
                                              Fluttertoast.showToast(
                                                  msg: "Error fetching orders from database."
                                              );
                                              return Container();
                                            } else if (snapshot.hasData) {
                                              final orders = snapshot.data;
                                              List<Order> pendingOrders = [];
                                              if (orders!.isNotEmpty) {
                                                for (int index = 0;
                                                    index < orders.length;
                                                    index += 1) {
                                                  bool orderRejected = false;
                                                  if (Provider.of<OrderControllerProvider>(
                                                              context,
                                                              listen: false)
                                                          .acceptedOrder !=
                                                      "NULL") {
                                                    if (orders[index].status ==
                                                        OrderStatus.InProcess) {
                                                      pendingOrders.add(orders[index]);
                                                    }
                                                  }
                                                  if (orders[index].status ==
                                                      OrderStatus.Pending) {
                                                    for (var id in Provider.of<
                                                                OrderControllerProvider>(
                                                            context,
                                                            listen: false)
                                                        .rejectedOrders) {
                                                      if (id == orders[index].orderId) {
                                                        orderRejected = true;
                                                      }
                                                    }
                                                    if (!orderRejected) {
                                                      pendingOrders.add(orders[index]);
                                                    }
                                                  }
                                                }
                                              }
                                              if (pendingOrders.isEmpty) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Lottie.asset(
                                                            "assets/animations/Order_Looking.json",
                                                            height: 250),
                                                        CustomGrandText(
                                                            text: "No orders found!!!"),
                                                        const Text(
                                                            "Don't worry we are continuously looking for orders."),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return Column(
                                                  children: [
                                                    ...List.generate(
                                                        pendingOrders.length,
                                                            (index) => Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              vertical: 8.0),
                                                          child: OrderCard(
                                                            order: pendingOrders[
                                                            index],
                                                            showPrice: true,
                                                            userId: userId,
                                                            isOffer: false,
                                                          ),
                                                        ))
                                                  ],
                                                );
                                              }
                                            } else {
                                              return SizedBox(
                                                height:
                                                MediaQuery.of(context).size.width,
                                                child: Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    const Center(
                                                        child:
                                                        CircularProgressIndicator()),
                                                    const Gap(20),
                                                    CustomGrandText(
                                                        text: "Looking for Orders"),
                                                  ],
                                                ),
                                              );
                                            }
                                          });
                                    },
                                  )
                                ],
                              );
                            // }
                            // else{
                            //   return const Center(child: CircularProgressIndicator());
                            // }
                          // });
                        // },
                      // );
                    } else {
                      return const SizedBox(
                          height: 250,
                          child: Center(child: CircularProgressIndicator()));
                    }
                  });
            },
          )),
        ],
      ),
    );
  }
}

class OrderCard extends StatefulWidget {
  final Order order;
  final bool showPrice;
  final String userId;
  final bool isOffer;

  OrderCard({super.key, required this.order, required this.showPrice,required this.userId, required this.isOffer});

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  final priceController = TextFieldController();
  bool isSelected = false;
  int price = 2000;
  // bool showPrice = false;
  bool isOrderApproved = false;
  bool isLoading = false;

  //Timer properties
  int countDownDuration = 6000;
  Timer? countDownTimer;
  int _currentTickerValue = 0;

  @override
  void initState() {
    super.initState();
    if(widget.isOffer) startTimer();
    price = widget.order.price;
    priceController.controller.text = "$price";
    if (widget.userId != null) {
      //if user id is provided
      //check if the order status is InProgress and driver specifically selected that particular order
      //and also make sure that the InProcess order' driverId is same is the id of the user.
      isOrderApproved = widget.order.status == OrderStatus.InProcess &&
          Provider.of<OrderControllerProvider>(context, listen: false)
                  .acceptedOrder ==
              widget.order.orderId &&
          widget.order.driverId == widget.userId;
      if(isOrderApproved){
        navigationTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Ink(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(kDefaultRounding)),
                  child: InkWell(
                    onTap: () => setState(() => widget.order.orderId !=
                            Provider.of<OrderControllerProvider>(context,
                                    listen: false)
                                .acceptedOrder
                        ? isSelected = !isSelected
                        : null),
                    child: Column(
                      children: [
                        _requestedBy(context, widget.order),
                        const RadialGradientDivider(),
                        _orderInfo(context,
                            image: "package_send",
                            section1: "From",
                            section2: "Total Weight",
                            sectionContent1: widget.order.address.from.address,
                            sectionContent2:
                                "${widget.order.package.properties.maxWeight} kg"),
                        const Gap(10),
                        _orderInfo(context,
                            image: "package_receive",
                            section1: "To",
                            section2: "Status",
                            sectionContent1: widget.order.address.to.address,
                            sectionContent2: widget.order.status.name,
                            haveStatusIcon: false),
                        const Gap(10),
                        isSelected ? const RadialGradientDivider() : Container(),
                        widget.showPrice
                            ? AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(kDefaultRounding),
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.background
                                      : Colors.transparent,
                                ),
                                child: Column(
                                  children: [
                                    const Gap(7),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        CustomGrandText(
                                            text: widget.order.orderId ==
                                                    Provider.of<OrderControllerProvider>(
                                                            context,
                                                            listen: false)
                                                        .acceptedOrder
                                                ? "Your Offer"
                                                : "Offered"),
                                        CustomPriceSection(
                                          controller: priceController,
                                          onMinusLongPressed: isSelected
                                              ? () {
                                                  if (price != 0) {
                                                    setState(() {
                                                      price -= 100;
                                                      priceController.controller
                                                          .text = "$price";
                                                    });
                                                  }
                                                }
                                              : null,
                                          onMinusPressed: isSelected
                                              ? () {
                                                  if (price != 0) {
                                                    setState(() {
                                                      price -= 1;
                                                      priceController.controller
                                                          .text = "$price";
                                                    });
                                                  }
                                                }
                                              : null,
                                          onPlusLongPressed: isSelected
                                              ? () {
                                                  if (!(price >=
                                                      widget.order.price + 500)) {
                                                    setState(() {
                                                      price =
                                                          widget.order.price + 500;
                                                      priceController.controller
                                                          .text = "$price";
                                                    });
                                                  }
                                                }
                                              : null,
                                          onPlusPressed: isSelected
                                              ? () {
                                                  if (!(price >=
                                                      widget.order.price + 500)) {
                                                    setState(() {
                                                      price += 1;
                                                      priceController.controller
                                                          .text = "$price";
                                                    });
                                                  }
                                                }
                                              : null,
                                        ),
                                        // buildBackAndNext(),
                                      ],
                                    ),
                                    isSelected
                                        ? const RadialGradientDivider()
                                        : Container(),
                                    isSelected
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              MaterialButton(
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            kDefaultRounding)),
                                                elevation: 0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                onPressed: () {
                                                  //Add order to rejected orders list
                                                  Provider.of<OrderControllerProvider>(
                                                          context,
                                                          listen: false)
                                                      .rejectedOrders
                                                      .add(widget.order.orderId);
                                                  setState(() {});
                                                },
                                                child: Text("Reject",
                                                    style: poppins_bold),
                                              ),
                                              MaterialButton(
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            kDefaultRounding)),
                                                color: greenishColor,
                                                onPressed: () async {
                                                  setState(() => isLoading = true);
                                                  setState(() {
                                                    Provider.of<OrderControllerProvider>(
                                                                context,
                                                                listen: false)
                                                            .acceptedOrder =
                                                        widget.order.orderId;
                                                    isSelected = false;
                                                  });
                                                  final newOrder = widget.order;
                                                  newOrder.price = int.parse(
                                                      priceController
                                                          .controller.text);
                                                  newOrder.orderId = "${newOrder.orderId}_${widget.userId!}";
                                                  await Provider.of<
                                                              OrderControllerProvider>(
                                                          context,
                                                          listen: false)
                                                      .offerOrder(newOrder);
                                                  Provider.of<OrderControllerProvider>(context, listen:false).rejectedOrders.add(widget.order.orderId);
                                                  setState(() => isLoading = false);
                                                },
                                                child: Text("Accept",
                                                    style: poppins_bold),
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    isSelected ? const Gap(3) : Container(),
                                    Provider.of<OrderControllerProvider>(context,
                                                    listen: false)
                                                .acceptedOrder ==
                                            widget.order.orderId
                                        ? LoadingAnimationWidget.prograssiveDots(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            size: 40)
                                        : Container(),
                                    _currentTickerValue > 0
                                        ? LinearProgressIndicator(
                                            borderRadius: BorderRadius.circular(40),
                                            value: _currentTickerValue /
                                                countDownDuration,
                                          )
                                        : Container(),
                                  ],
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
                isOrderApproved
                    ? Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius:
                                  BorderRadius.circular(kDefaultRounding)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 100, color: Colors.green),
                              Text(
                                "Order Accepted",
                                style: poppins_bold.copyWith(
                                  color: Colors.green,
                                  fontSize: 24,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
        // loadingBackgroundBlur(isLoading),
        // loadingIndicator(context, isLoading),
      ],
    );
  }

  Widget _requestedBy(context, Order order) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: order.customerImage == "NULL"
                  ? Image.asset(
                      "assets/images/avatars/user_02a.png",
                      height: 40,
                    )
                  : Image.network(order.customerImage, height: 40),
            ),
            const Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _orderSectionTitle(context, "Requested by"),
                Text(order.customerName),
              ],
            ),
          ],
        ),
        if (order.vehicleCategory == "Pickup")
          Image.asset("assets/images/resources/pickup.png", height: 50),
        if (order.vehicleCategory == "Mini Truck")
          Image.asset("assets/images/resources/mini.png", height: 50),
        if (order.vehicleCategory == "2-Axle Truck")
          Image.asset("assets/images/resources/truck1.png", height: 50),
        if (order.vehicleCategory == "Large Truck")
          Image.asset("assets/images/resources/large.png", height: 50),
      ],
    );
  }

  Widget _orderInfo(
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
                _orderSectionTitle(context, section1),
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
            _orderSectionTitle(context, section2),
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

  Text _orderSectionTitle(context, String title) {
    return Text(
      title,
      style: poppins_bold.copyWith(
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8)),
    );
  }

  Future<void> startTimer() async {
    setState(() {
      isLoading = true;
    });
    _currentTickerValue = countDownDuration;
    countDownTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (_currentTickerValue > 0) {
        setState(() {
          _currentTickerValue--;
        });
      } else {
        setState(() {
          isLoading = false;
          Provider.of<OrderControllerProvider>(context, listen: false).rejectedOrders.remove(widget.order.orderId.split("_")[0]);
          Provider.of<OrderControllerProvider>(context, listen:false).acceptedOrder = "NULL";
          countDownTimer!.cancel();
          //as the order is not accepted by the customer so it is automatically rejected
          // Provider.of<OrderControllerProvider>(context, listen: false)
          //     .rejectedOrders
          //     .add(Provider.of<OrderControllerProvider>(context, listen: false)
          //         .acceptedOrder);
        });
        print("timer is out ${widget.order.orderId}");
        final answer = await Provider.of<OrderControllerProvider>(context, listen: false)
            .deleteOfferOrder("${widget.order.orderId}");
        print(answer);
      }
    });
  }

  Future<void> navigationTimer() async {
    countDownDuration = 5000;
    Fluttertoast.showToast(msg: "Navigating to tracking in 5 sec...");
    _currentTickerValue = countDownDuration;
    countDownTimer = Timer.periodic(const Duration(milliseconds: 1), (timer) async {
      if (_currentTickerValue > 0) {
        setState(() {
          _currentTickerValue--;
        });
      } else {
        setState(() {
          countDownTimer!.cancel();
        });
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> TrackOrderScreen()));
      }
    });
  }
}
