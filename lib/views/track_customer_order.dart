import 'package:backcaps_logistics/views/home_screens/customer_screens/send_parcel_screens/send_parcel_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:backcaps_logistics/core/controllers/order_controller.dart';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:backcaps_logistics/structure/Customer.dart';
import 'package:backcaps_logistics/structure/enums/OrderStatus.dart';
import 'package:backcaps_logistics/views/chat_screen.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/customer_home_screen.dart';
import 'package:backcaps_logistics/views/home_screens/driver_screens/find_orders_screen.dart';
import 'package:backcaps_logistics/views/order_history.dart';
import 'package:backcaps_logistics/views/source_destination_screen.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:backcaps_logistics/structure/Address.dart' as toFromAddress;
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../structure/GeoLocation.dart' as geolocation;
import '../core/constants/apiKeys.dart';
import '../core/constants/constants.dart';
import '../core/controllers/chat_controller.dart';
import '../core/controllers/user_controller.dart';
import '../core/utils/utils.dart';
import '../structure/Chat.dart';
import '../structure/Order.dart';
import '../widgets/custom_outlined_text_field.dart';
import '../widgets/static_widgets.dart';
import 'package:backcaps_logistics/structure/Location.dart' as structureAddress;
class TrackCustomerOrder extends StatefulWidget {
  const TrackCustomerOrder({super.key});

  @override
  State<TrackCustomerOrder> createState() => _TrackCustomerOrderState();
}

class _TrackCustomerOrderState extends State<TrackCustomerOrder> {
  bool areFieldsVisible = true;
  late LatLngBounds _bounds;
  Completer<GoogleMapController> _mapController = Completer();
  LatLng currentPosition = initialLocation;
  CameraPosition initialCameraPosition =
  const CameraPosition(target: initialLocation, zoom: 14.0);
  bool isLoading = false;
  GeoCode geoCode = GeoCode(apiKey: geocoder_api_key);
  double latitude = 0.0;
  double longitude = 0.0;
  late TimeDistanceMatrix timeDistanceMatrix;
  bool distanceMatrixFound = false;
  bool pickupPointActive = true;
  bool toggleLocationFAB = false;

  // bool pathDefined = false;
  Map<PolylineId, Polyline> polylines = {};
  OpenRouteService mapService = OpenRouteService(
      apiKey: open_route_api_key, profile: ORSProfile.drivingHgv);
  StreamSubscription<Position>? positionStreamSubscription;
  bool firstRun = false;

  // Placeholder for order destination
  LatLng orderDestination = LatLng(0, 0);

  Future<void> getCurrentLocation() async {
    try {
      setState(() {
        isLoading = true;
      });

      geolocation.Location location = geolocation.Location();
      await location.checkIfAccessGranted();

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        bool enableLocationServices = await Geolocator.openLocationSettings();
        if (!enableLocationServices) {
          throw Exception('Location services are disabled.');
        }
      }

      // Start listening to location updates
      positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((Position position) async {
        setState(() {
          currentPosition = LatLng(position.latitude, position.longitude);
          initialCameraPosition =
              CameraPosition(target: currentPosition, zoom: 14.0);
        });
        await updatePolyline(); // Update the polyline when the location changes
        _goToCurrentLocation();
      });

      // Initial polyline update
      await updatePolyline();
    } catch (e) {
      Utils.showAlertPopup(context, "Something went wrong", "Error: $e");
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<LatLng>> getPolylinePoints({
    required double sourceLatitude,
    required double sourceLongitude,
    required double destinationLatitude,
    required double destinationLongitude,
  }) async {
    final List<ORSCoordinate> routeCoordinates =
    await mapService.directionsRouteCoordsGet(
      profileOverride: ORSProfile.drivingCar,
      startCoordinate:
      ORSCoordinate(latitude: sourceLatitude, longitude: sourceLongitude),
      endCoordinate: ORSCoordinate(
          latitude: destinationLatitude, longitude: destinationLongitude),
    );
    final List<LatLng> routePoints = routeCoordinates
        .map((coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
        .toList();

    final List<ORSCoordinate> coordinates = [
      ORSCoordinate(latitude: sourceLatitude, longitude: sourceLongitude),
      ORSCoordinate(
          latitude: destinationLatitude, longitude: destinationLongitude),
    ];

    timeDistanceMatrix = await mapService.matrixPost(
      locations: coordinates,
      metrics: ['duration', 'distance'],
      units: 'km',
      profileOverride: ORSProfile.drivingHgv,
    );
    distanceMatrixFound = true;
    print(timeDistanceMatrix.toString());

    return routePoints;
  }

  void generatePolylineFromPoints(
      List<LatLng> polylineCoordinates, {
        required double sourceLatitude,
        required double sourceLongitude,
        required double destinationLatitude,
        required double destinationLongitude,
      }) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
      _bounds = boundsFromLatLngList([
        LatLng(sourceLatitude, sourceLongitude),
        LatLng(destinationLatitude, destinationLongitude)
      ]);
    });

    // _mapController.future.then((GoogleMapController controller) {
    //   return controller.animateCamera(
    //     CameraUpdate.newLatLngBounds(
    //       _bounds,
    //       100,
    //     ),
    //   );
    // });
  }

  LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, y0, x1, y1;

    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }

    return LatLngBounds(
      southwest: LatLng(x0!, y0!),
      northeast: LatLng(x1!, y1!),
    );
  }

  Future<void> updatePolyline() async {
    if (orderDestination.latitude != 0 && orderDestination.longitude != 0) {
      final polylinePoints = await getPolylinePoints(
        sourceLatitude: currentPosition.latitude,
        sourceLongitude: currentPosition.longitude,
        destinationLatitude: orderDestination.latitude,
        destinationLongitude: orderDestination.longitude,
      );
      generatePolylineFromPoints(
        polylinePoints,
        sourceLatitude: currentPosition.latitude,
        sourceLongitude: currentPosition.longitude,
        destinationLatitude: orderDestination.latitude,
        destinationLongitude: orderDestination.longitude,
      );
    }
  }

  openDialPad(String phoneNumber) async {
    Uri url = Uri(scheme: "tel", path: "0$phoneNumber");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Can't open dial pad.");
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  void _goToCurrentLocation() {
    if (_mapController.isCompleted) {
      _mapController.future.then((GoogleMapController controller) {
        controller
            .animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 15));
      });
    } else {
      print("GoogleMapController is not yet available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          body: Consumer<OrderControllerProvider>(
            builder: (context, orderControllerProvider, _) {
              return FutureBuilder(
                future: orderControllerProvider.getCustomerOrders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    Fluttertoast.showToast(
                        msg: "Error fetching orders. Contact developer.");
                    return Container();
                  } else if (snapshot.hasData) {
                    final orders = snapshot.data;
                    late Order order;
                    if (orders!.isEmpty && !firstRun) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        firstRun = true;
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Oops!!! No Order found"),
                                content: const Text(
                                    "Please place the order first."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SendParcelScreen())),
                                    child: const Text("Place Order"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RedirectUser())),
                                    child: const Text("Go Back"),
                                  )
                                ],
                              );
                            });
                      });
                    }
                    bool orderAssigned = false;
                    double userRating = 0.0;
                    //Scan the orders having InProcess/Shipped status only
                    for(var currentOrder in orders){
                      if(currentOrder.status == OrderStatus.Rated){
                        //Do nothing
                      }
                      else if(currentOrder.status == OrderStatus.Delivered && !firstRun){
                        firstRun = true;
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          showDialog(
                            barrierDismissible: false,
                              context: context, builder: (context){
                            return Consumer<UserControllerProvider>(builder: (context, userControllerProvider, _){
                              return FutureBuilder(future: userControllerProvider.getUserById(currentOrder.driverId), builder: (context, snapshot){
                                if(snapshot.hasError){
                                  Fluttertoast.showToast(msg: "Error fetching driver, contact developer");
                                  return Container();
                                }
                                else if(snapshot.hasData){
                                  final driver = snapshot.data!;
                                  return AlertDialog(

                                    title: Text('Rate Driver'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(
                                          radius: 40,
                                          backgroundImage: NetworkImage(driver.imageUrl),
                                        ),
                                        SizedBox(height: 10),
                                        Text(driver.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        Text('Current Rating: ${driver.rating}'),
                                        SizedBox(height: 10),
                                        RatingBar.builder(
                                          initialRating: 0,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                          onRatingUpdate: (rating) {
                                            userRating = rating;
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          final currentDeliveries = driver.totalDeliveries + 1;
                                          final previousTotalRating = driver.rating * driver.totalDeliveries;
                                          final newTotalRating = previousTotalRating + userRating;
                                          final newRating = newTotalRating / currentDeliveries;
                                          final updateDriver = driver;
                                          updateDriver.rating = newRating;
                                          updateDriver.totalDeliveries = currentDeliveries;
                                          Provider.of<UserControllerProvider>(context, listen: false).updateUserById(updateDriver.toJson(), currentOrder.driverId);
                                          currentOrder.status = OrderStatus.Rated;
                                          Provider.of<OrderControllerProvider>(context, listen: false).update(currentOrder);
                                          Fluttertoast.showToast(msg: "Driver rated successfully.");
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RedirectUser()));
                                        },
                                        child: Text('Submit'),
                                      ),
                                    ],
                                  );
                                }
                                else {
                                  return const SizedBox(height:250, child:Center(child:CircularProgressIndicator()));
                                }
                              });
                            },);
                          });
                        });
                        break;
                      }
                      else if(currentOrder.status == OrderStatus.InProcess || currentOrder.status == OrderStatus.Shipped){
                          orderAssigned = true;
                          order = currentOrder;
                          break;
                      }
                      else if(currentOrder.status == OrderStatus.WaitApproval && !firstRun){
                        firstRun = true;
                        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Oops!!! Your order has not been approved yet"),
                                  content: const Text(
                                      "Please be patient your order will be approved shortly."),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SendParcelScreen())),
                                      child: const Text("Place Order"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RedirectUser())),
                                      child: const Text("Go Back"),
                                    )
                                  ],
                                );
                              });
                        });
                      }
                    }
                    if(!orderAssigned && !firstRun){
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        firstRun = true;
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Oops!!! No Order found"),
                                content: const Text(
                                    "Please place order first to start tracking."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SendParcelScreen())),
                                    child: const Text("Place Order"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> RedirectUser())),
                                    child: const Text("Go Back"),
                                  )
                                ],
                              );
                            });
                      });
                    }
                    else if (orderAssigned){
                      // order = orders.first;
                      // Set the order destination only if it's not set
                      if (order.status == OrderStatus.InProcess) {
                        orderDestination = LatLng(order.address.from.latitude,
                            order.address.from.longitude);
                      } else {
                        orderDestination = LatLng(order.address.to.latitude,
                            order.address.to.longitude);
                      }
                      return Consumer<UserControllerProvider>(builder: (context, userControllerProvider, _){
                        return FutureBuilder(future: userControllerProvider.getUserById(order.driverId), builder: (context, snapshot){
                          if(snapshot.hasError){
                            Fluttertoast.showToast(msg: "Unable to fetch driver. Contact developer");
                            return Container();
                          }else if (snapshot.hasData){
                            final driver = snapshot.data;
                            return Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: initialCameraPosition,
                                  myLocationButtonEnabled: false,
                                  myLocationEnabled: true,
                                  onMapCreated: (GoogleMapController controller) async {
                                    setState(() {
                                      _mapController.complete(controller);
                                    });
                                  },
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId("current location"),
                                      infoWindow: InfoWindow(title: "Source"),
                                      position: LatLng(driver.location.latitude, driver.location.longitude),
                                    ),
                                    // pathDefined
                                    //     ? Marker(
                                    //         markerId: const MarkerId("drop-of"),
                                    //         infoWindow: InfoWindow(title: "Destination"),
                                    //         position: LatLng(destinationAddress.latitude,
                                    //             destinationAddress.longitude),
                                    //       )
                                    //     : Marker(
                                    //         markerId: const MarkerId("moving"),
                                    //         position: currentPosition,
                                    //       ),
                                  },
                                  padding: const EdgeInsets.only(bottom: 300),
                                  onCameraMove: (CameraPosition position) async {
                                    await getPolylinePoints(
                                        sourceLatitude: driver.location.latitude,
                                        sourceLongitude: driver.location.longitude,
                                        destinationLatitude: orderDestination.latitude,
                                        destinationLongitude: orderDestination.longitude)
                                        .then((value) => generatePolylineFromPoints(
                                      value,
                                      sourceLatitude: driver.location.latitude,
                                      sourceLongitude: driver.location.longitude,
                                      destinationLatitude: orderDestination.latitude,
                                      destinationLongitude: orderDestination.longitude,
                                    ));
                                    // setState(() {
                                    //   currentPosition = position.target;
                                    // });
                                  },
                                  onCameraIdle: () async {
                                    await getPolylinePoints(
                                        sourceLatitude: driver.location.latitude,
                                        sourceLongitude: driver.location.longitude,
                                        destinationLatitude: orderDestination.latitude,
                                        destinationLongitude: orderDestination.longitude)
                                        .then((value) => generatePolylineFromPoints(
                                      value,
                                      sourceLatitude: driver.location.latitude,
                                      sourceLongitude: driver.location.longitude,
                                      destinationLatitude: orderDestination.latitude,
                                      destinationLongitude: orderDestination.longitude,
                                    ));
                                    // await getAddressFromMarker(currentPosition.latitude, currentPosition.longitude).then((address) {
                                    //   if (pickupPointActive) {
                                    //     pickupAddress = structureAddress.Location(
                                    //         latitude: currentPosition.latitude,
                                    //         longitude: currentPosition.longitude,
                                    //         address: "${address.reversed.last.street != "" ? '${address.reversed.last.street}, ' : ""}${address.reversed.last.locality != "" ? '${address.reversed.last.locality}' : "${address.reversed.last.administrativeArea}"}");
                                    //   } else {
                                    //     destinationAddress = structureAddress.Location(
                                    //         latitude: currentPosition.latitude,
                                    //         longitude: currentPosition.longitude,
                                    //         address: "${address.reversed.last.street != "" ? '${address.reversed.last.street}, ' : ""}${address.reversed.last.locality != "" ? '${address.reversed.last.locality}' : "${address.reversed.last.administrativeArea}"}");
                                    //   }
                                    // });
                                  },
                                  polylines: Set<Polyline>.of(polylines.values),
                                ),
                                SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: IconButton.filledTonal(
                                      onPressed: () {
                                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RedirectUser()));
                                      },
                                      icon: const Icon(Icons.arrow_back),
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            FloatingActionButton(
                                              onPressed: () {
                                                if(toggleLocationFAB){
                                                  _goToCurrentLocation();
                                                  setState(() {
                                                    toggleLocationFAB = !toggleLocationFAB;
                                                  });
                                                }else{
                                                  setState(() {
                                                    _bounds = boundsFromLatLngList([
                                                      LatLng(driver.location.latitude, driver.location.longitude),
                                                      LatLng(orderDestination.latitude, orderDestination.longitude)
                                                    ]);
                                                    toggleLocationFAB = !toggleLocationFAB;
                                                  });
                                                  _mapController.future.then((GoogleMapController controller){
                                                    return controller.animateCamera(
                                                      CameraUpdate.newLatLngBounds(
                                                        _bounds,
                                                        100,
                                                      ),
                                                    );
                                                  });
                                                }

                                              },
                                              child:
                                              toggleLocationFAB? Icon(Icons.my_location_sharp) : Icon(Icons.map_outlined),
                                            ),
                                          ],
                                        ),
                                      ),
                                      buildBottomSheet(context, order, orders),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }else{
                            return const SizedBox(height:250, child: Center(child: CircularProgressIndicator()));
                          }
                        });
                      });
                    }
                    return Container();
                  } else {
                    return const SizedBox(
                      height: 250,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading),
      ],
    );
  }

  AnimatedContainer buildBottomSheet(
      BuildContext context, Order order, List<dynamic> orders) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(kDefaultRounding)),
        color: Theme.of(context).colorScheme.background,
      ),
      height: areFieldsVisible ? 290 : 0,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(10),
            Text(
              order.status == OrderStatus.InProcess ? "Driver is on the way" : "Your order is being delivered",
              style: poppins_bold.copyWith(fontSize: 16),
            ),
            const Gap(2),
            Text(
              "Thank you for your patience.",
              style: poppins.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5)),
            ),
            const RadialGradientDivider(),
            FutureBuilder(
              future: Provider.of<UserControllerProvider>(context)
                  .getUserById(orders.first.driverId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final driver = snapshot.data;
                  if(order.status == OrderStatus.InProcess){
                    orderDestination = LatLng(driver.location.latitude, driver.location.longitude);
                  }else if (order.status == OrderStatus.Shipped){
                    // orderDestination = LatLng(order.)
                  }
                  Widget imageWidget;
                  if (driver.imageUrl == "NULL") {
                    imageWidget =
                        Image.asset("assets/images/avatars/user_02a.png");
                  } else {
                    imageWidget = Image.network(driver.imageUrl);
                  }
                  return ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: imageWidget),
                    title: Text(driver.name),
                    subtitle: Text("+92${driver.phoneNumber}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                            onPressed: () async {
                              // await openDialPad(customer.phoneNumber);
                              FlutterPhoneDirectCaller.callNumber(
                                  "0${driver.phoneNumber}");
                            },
                            icon: const Icon(Icons.call_outlined)),
                        IconButton.filledTonal(
                            onPressed: () {
                              Chat chat = Chat(
                                text: "NULL",
                                email: "NULL",
                              );
                              chat.chatId =
                              "${driver.userId}_${Provider.of<UserControllerProvider>(context, listen: false).auth.currentUser!.uid}";
                              Provider.of<ChatControllerProvider>(context,
                                  listen: false)
                                  .create(chat);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          chatPerson: chat.chatId,
                                          user: driver)));
                            },
                            icon: const Icon(Icons.chat_outlined)),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
            ShippingCard(
              order: order,
            ),
          ],
        ),
      ),
    );
  }
  //
  // Widget buildGoogleMap(String driverId) {
  //   // return
  // }
}
