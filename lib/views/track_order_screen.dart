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
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
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

  Future<List<Placemark>> getAddressFromMarker(
      double latitude, double longitude) async {
    setState(() {
      isLoading = true;
    });
    List<Placemark> placeMark =
    await placemarkFromCoordinates(latitude, longitude);
    setState(() {
      isLoading = false;
    });
    return placeMark;
    // final address =  await geoCode.reverseGeocoding(latitude: latitude, longitude: longitude);
    // return address;
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
                future: orderControllerProvider.getDriverOrders(),
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
                                    "Please find order first to start tracking."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FindOrdersScreen())),
                                    child: const Text("Find Order"),
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
                    //Scan the orders having InProcess/Shipped status only
                    for(var currentOrder in orders){
                      if(currentOrder.status == OrderStatus.InProcess || currentOrder.status == OrderStatus.Shipped){
                        orderAssigned = true;
                        order = currentOrder;
                        break;
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
                                    "Please find order first to start tracking."),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                FindOrdersScreen())),
                                    child: const Text("Find Order"),
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
                      // Set the order destination only if it's not set
                      if (order.status == OrderStatus.InProcess) {
                        orderDestination = LatLng(order.address.from.latitude,
                            order.address.from.longitude);
                      } else {
                        orderDestination = LatLng(order.address.to.latitude,
                            order.address.to.longitude);
                      }
                      return Stack(
                        children: [
                          buildGoogleMap(),
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: IconButton.filledTonal(
                                onPressed: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const RedirectUser()));
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
                                                LatLng(currentPosition.latitude, currentPosition.longitude),
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
                                buildBottomSheet(context, order),
                              ],
                            ),
                          ),
                        ],
                      );
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
      BuildContext context, Order order) {
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
              "Please reach the destination location",
              style: poppins_bold.copyWith(fontSize: 16),
            ),
            const Gap(2),
            Text(
              "You are required to reach on time.",
              style: poppins.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onBackground
                      .withOpacity(0.5)),
            ),
            const RadialGradientDivider(),
            if (distanceMatrixFound)
              timeDistanceMatrix.distances.first.last <= 1 &&
                      order.status == OrderStatus.InProcess
                  ? Custom_Rectangular_button(
                      title: "Reached the destination",
                      onPressed: () {
                        setState(() {
                          order.status = OrderStatus.Shipped;
                          orderDestination = LatLng(order.address.to.latitude, order.address.to.longitude);
                        });

                        Provider.of<OrderControllerProvider>(context,
                                listen: false)
                            .update(order);
                        _goToCurrentLocation();
                      },
                    )
                  : Container(),
            if (distanceMatrixFound)
              timeDistanceMatrix.distances.first.last <= 1 &&
                  order.status == OrderStatus.Shipped
                  ? Custom_Rectangular_button(
                title: "Complete Order",
                onPressed: () {
                  Utils.showConfirmationDialogue(context, title: "Complete Order", content: "Are you sure you want to complete the order?", confirmText: "Complete", onConfirm: (){
                    setState(() {
                      order.status = OrderStatus.Delivered;
                    });
                    Provider.of<OrderControllerProvider>(context,
                        listen: false)
                        .update(order);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const OrderHistory(role: "Role.Driver")));
                  });
                },
              )
                  : Container(),
            FutureBuilder(
              future: Provider.of<UserControllerProvider>(context)
                  .getUserById(order.customerId),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final customer = snapshot.data;
                  Widget imageWidget;
                  if (customer.imageUrl == "NULL") {
                    imageWidget =
                        Image.asset("assets/images/avatars/user_02a.png");
                  } else {
                    imageWidget = Image.network(customer.imageUrl);
                  }
                  return ListTile(
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(80),
                        child: imageWidget),
                    title: Text(customer.name),
                    subtitle: Text("+92${customer.phoneNumber}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                            onPressed: () async {
                              // await openDialPad(customer.phoneNumber);
                              FlutterPhoneDirectCaller.callNumber(
                                  "0${customer.phoneNumber}");
                            },
                            icon: const Icon(Icons.call_outlined)),
                        IconButton.filledTonal(
                            onPressed: () {
                              Chat chat = Chat(
                                text: "NULL",
                                email: "NULL",
                              );
                              chat.chatId =
                                  "${Provider.of<UserControllerProvider>(context, listen: false).auth.currentUser!.uid}_${customer.userId}";
                              Provider.of<ChatControllerProvider>(context,
                                      listen: false)
                                  .create(chat);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          chatPerson: chat.chatId,
                                          user: customer)));
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

  GoogleMap buildGoogleMap() {
    return GoogleMap(
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
          position: currentPosition,
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
                sourceLatitude: currentPosition.latitude,
                sourceLongitude: currentPosition.longitude,
                destinationLatitude: orderDestination.latitude,
                destinationLongitude: orderDestination.longitude)
            .then((value) => generatePolylineFromPoints(
                  value,
                  sourceLatitude: currentPosition.latitude,
                  sourceLongitude: currentPosition.longitude,
                  destinationLatitude: orderDestination.latitude,
                  destinationLongitude: orderDestination.longitude,
                ));
        await getAddressFromMarker(
            currentPosition.latitude, currentPosition.longitude)
            .then((address) {
          print(address);
          final newAddress = structureAddress.Location(
              latitude: currentPosition.latitude,
              longitude: currentPosition.longitude,
              address:
              "${address.reversed.last.street != "" ? '${address.reversed.last.street}, ' : ""}${address.reversed.last.locality != "" ? '${address.reversed.last.locality}' : "${address.reversed.last.administrativeArea}"}");
          Provider.of<UserControllerProvider>(context, listen:false).updateLocation(newAddress.address, newAddress.latitude, newAddress.longitude);
        });
        // setState(() {
        //   currentPosition = position.target;
        // });
      },
      onCameraIdle: () async {
        await getPolylinePoints(
                sourceLatitude: currentPosition.latitude,
                sourceLongitude: currentPosition.longitude,
                destinationLatitude: orderDestination.latitude,
                destinationLongitude: orderDestination.longitude)
            .then((value) => generatePolylineFromPoints(
                  value,
                  sourceLatitude: currentPosition.latitude,
                  sourceLongitude: currentPosition.longitude,
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
    );
  }
}
