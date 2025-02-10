import 'dart:async';
import 'package:backcaps_logistics/core/utils/text_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:gap/gap.dart';
import 'package:backcaps_logistics/structure/Address.dart' as toFromAddress;
import 'package:geocode/geocode.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route_service/open_route_service.dart';
import '../../structure/GeoLocation.dart' as geolocation;
import '../core/constants/apiKeys.dart';
import '../core/constants/constants.dart';
import '../core/utils/utils.dart';
import '../widgets/custom_outlined_text_field.dart';
import '../widgets/static_widgets.dart';
import 'package:backcaps_logistics/structure/Location.dart' as structureAddress;

class SourceDestinationScreen extends StatefulWidget {
  const SourceDestinationScreen({super.key});

  @override
  State<SourceDestinationScreen> createState() =>
      _SourceDestinationScreenState();
}

class _SourceDestinationScreenState extends State<SourceDestinationScreen> {
  bool areFieldsVisible = true;

  // late GoogleMapController _mapController;
  late LatLngBounds _bounds;
  Completer<GoogleMapController> _mapController = Completer();
  LatLng currentPosition = initialLocation;
  CameraPosition initialCameraPosition =
      const CameraPosition(target: initialLocation, zoom: 14.0);
  bool isLoading = false;
  GeoCode geoCode = GeoCode(apiKey: geocoder_api_key);
  structureAddress.Location pickupAddress =
      structureAddress.Location(latitude: 0, longitude: 0, address: "");
  structureAddress.Location destinationAddress =
      structureAddress.Location(latitude: 0, longitude: 0, address: "");
  late TimeDistanceMatrix timeDistanceMatrix;
  bool pickupPointActive = true;
  bool pathDefined = false;
  Map<PolylineId, Polyline> polylines = {};
  OpenRouteService mapService = OpenRouteService(apiKey: open_route_api_key,profile: ORSProfile.drivingHgv);

  Future<void> getCurrentLocation() async {
    try {
      setState(() {
        isLoading = true;
      });

      geolocation.Location location = geolocation.Location();
      await location.checkIfAccessGranted();

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Prompt the user to enable location services
        bool enableLocationServices = await Geolocator.openLocationSettings();
        if (!enableLocationServices) {
          // Handle the case where the user decides not to enable location services
          throw Exception('Location services are disabled.');
        }
      }

      await location.getCurrentLocation();

      print("Current location is retrieved");
      setState(() {
        currentPosition = LatLng(location.latitude, location.longitude);
        print("Location fetched as $currentPosition");
        initialCameraPosition =
            CameraPosition(target: currentPosition, zoom: 14.0);
      });
      _goToCurrentLocation();
    } catch (e) {
      Utils.showAlertPopup(context, "Something went wrong", "Error: $e");
      print(e);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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

  Future<List<LatLng>> getPolylinePoints() async {
    final List<ORSCoordinate> routeCoordinates =
        await mapService.directionsRouteCoordsGet(
      profileOverride: ORSProfile.drivingCar,
      startCoordinate: ORSCoordinate(
          latitude: pickupAddress.latitude, longitude: pickupAddress.longitude),
      endCoordinate: ORSCoordinate(
          latitude: destinationAddress.latitude,
          longitude: destinationAddress.longitude),
    );
    final List<LatLng> routePoints = routeCoordinates
        .map((coordinate) => LatLng(coordinate.latitude, coordinate.longitude))
        .toList();

    final List<ORSCoordinate> coordinates = [
      ORSCoordinate(latitude: pickupAddress.latitude, longitude:  pickupAddress.longitude),
      ORSCoordinate(latitude: destinationAddress.latitude, longitude:  destinationAddress.longitude),
    ];

    //Following is the matrix calculator
    timeDistanceMatrix = await mapService.matrixPost(
      locations: coordinates,
      metrics: ['duration', 'distance'],
      units: 'km',
      profileOverride: ORSProfile.drivingHgv,
    );
    print(timeDistanceMatrix.toString());

    return routePoints;
  }

  void generatePolylineFromPoints(List<LatLng> polylineCoordinates) async {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 5);
    setState(() {
      polylines[id] = polyline;

      // Calculate bounds to encapsulate both pickup and destination points
      _bounds = boundsFromLatLngList([
        LatLng(pickupAddress.latitude, pickupAddress.longitude),
        LatLng(destinationAddress.latitude, destinationAddress.longitude)
      ]);
    });

    // Move camera to focus between the two points
    _mapController.future.then((GoogleMapController controller){
      return controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          _bounds,
          100,
        ),
      );
    });
  }

  // Function to calculate bounds from list of LatLng
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

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void _goToCurrentLocation() {
    if (currentPosition != null) {
      if (_mapController.isCompleted) {
        _mapController.future.then((GoogleMapController controller) {
          controller
              .animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 15));
        });
      } else {
        print("GoogleMapController is not yet available.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialCameraPosition,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              setState(() {
                _mapController.complete(controller);
              });
            },
            markers: {
              Marker(
                markerId: const MarkerId("pick-up"),
                infoWindow: InfoWindow(title: "Source"),
                position: pickupPointActive
                    ? currentPosition ?? initialCameraPosition.target
                    : LatLng(pickupAddress.latitude, pickupAddress.longitude),
              ),
              pathDefined
                  ? Marker(
                      markerId: const MarkerId("drop-of"),
                      infoWindow: InfoWindow(title: "Destination"),
                      position: LatLng(destinationAddress.latitude,
                          destinationAddress.longitude),
                    )
                  : Marker(
                      markerId: const MarkerId("moving"),
                      position: currentPosition,
                    ),
            },
            padding: const EdgeInsets.only(bottom: 300),
            onCameraMove: (CameraPosition position) {
              setState(() {
                if (!pathDefined) currentPosition = position.target;
                areFieldsVisible = false;
              });
            },
            onCameraIdle: () async {
              await getAddressFromMarker(
                      currentPosition.latitude, currentPosition.longitude)
                  .then((address) {
                //The pickupPointActive is a toggle button state /*
                // That is active till the user press confirm pickup button*/
                if (pickupPointActive) {
                  print(address);
                  pickupAddress = structureAddress.Location(
                      latitude: currentPosition.latitude,
                      longitude: currentPosition.longitude,
                      address:
                          "${address.reversed.last.street != "" ? '${address.reversed.last.street}, ' : ""}${address.reversed.last.locality != "" ? '${address.reversed.last.locality}' : "${address.reversed.last.administrativeArea}"}");
                } else {
                  destinationAddress = structureAddress.Location(
                      latitude: currentPosition.latitude,
                      longitude: currentPosition.longitude,
                      address:
                          "${address.reversed.last.street != "" ? '${address.reversed.last.street}, ' : ""}${address.reversed.last.locality != "" ? '${address.reversed.last.locality}' : "${address.reversed.last.administrativeArea}"}");
                }
              });
              setState(() {
                areFieldsVisible = true;
              });
            },
            polylines: Set<Polyline>.of(polylines.values),
          ),
          SafeArea(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: pathDefined
                ? IconButton.filledTonal(
                    onPressed: () => setState(() {
                          pickupPointActive = true;
                          pathDefined = false;
                          polylines.clear();
                        }),
                    icon: Icon(Icons.close))
                : IconButton.filledTonal(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back)),
          )),
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
                            getCurrentLocation();
                          },
                          child: const Icon(Icons.my_location_sharp),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(kDefaultRounding)),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    height: areFieldsVisible
                        ? pickupPointActive
                            ? 230
                            : pathDefined
                                ? 170
                                : 280
                        : 0,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Gap(10),
                          Text(
                            "${pathDefined ? 'Confirm' : 'Choose'} your ${pickupPointActive ? 'pick-up location' : !pathDefined ? 'drop-of location' : 'route'}",
                            style: poppins_bold.copyWith(fontSize: 16),
                          ),
                          const Gap(2),
                          Text(
                            "Drag the map to ${pathDefined ? 'view route' : "move the pin"}",
                            style: poppins.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onBackground
                                    .withOpacity(0.5)),
                          ),
                          const RadialGradientDivider(),
                          !pathDefined
                              ? location_card(
                                  isLoading: isLoading,
                                  address: pickupAddress.address,
                                  placeholder: "Pick-up Location",
                                  onPressed: () {
                                    setState(() {
                                      pickupPointActive = true;
                                    });
                                  },
                                )
                              : Container(),
                          !pickupPointActive && !pathDefined
                              ? const Gap(10)
                              : Container(),
                          !pickupPointActive && !pathDefined
                              ? location_card(
                                  isLoading: isLoading,
                                  address: destinationAddress.address,
                                  placeholder: "Drop-of Location",
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Please drag the map to select drop-of location.")));
                                  },
                                )
                              : Container(),
                          !pathDefined ? const Gap(10) : Container(),
                          pickupPointActive
                              ? Custom_Rectangular_button(
                                  title: "Confirm Pick-up Point",
                                  onPressed: () {
                                    setState(() {
                                      pickupPointActive = false;
                                    });
                                  },
                                )
                              : !pathDefined
                                  ? Custom_Rectangular_button(
                                      title: "Confirm Drop-of Point",
                                      onPressed: () async {
                                        // setState(() {
                                        //   // pathDefined=true;
                                        // });
                                        await getPolylinePoints()
                                            .then((value) =>
                                                generatePolylineFromPoints(
                                                    value))
                                            .then((value) => setState(
                                                () => pathDefined = true));
                                      },
                                    )
                                  : Custom_Rectangular_button(
                                      title: "Done",
                                      onPressed: () {
                                        toFromAddress.Address address = toFromAddress.Address(
                                            to: destinationAddress,
                                            from: pickupAddress);
                                        address.timeDistanceMatrix = timeDistanceMatrix;
                                        Navigator.pop(context, address);
                                      }),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class location_card extends StatelessWidget {
  const location_card({
    super.key,
    required this.isLoading,
    required this.address,
    required this.placeholder,
    required this.onPressed,
  });

  final bool isLoading;
  final String address;
  final String placeholder;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
      child: Material(
        // decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        // ),
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: CupertinoActivityIndicator(),
                      )
                    : Container(),
                Text(address == "" ? placeholder : address),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Custom_Rectangular_button extends StatelessWidget {
  final String title;
  final Function() onPressed;

  const Custom_Rectangular_button({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
      child: Material(
        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: poppins_bold.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
