import 'dart:async';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/apiKeys.dart';
import '../../core/utils/utils.dart';
import '../../structure/GeoLocation.dart' as geolocation;
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/constants.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  static const String id = "Location_Screen";

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  // late GoogleMapController _mapController;
  Completer<GoogleMapController> _mapController = Completer();
  LatLng currentPosition = initialLocation;
  CameraPosition initialCameraPosition =
      const CameraPosition(target: initialLocation, zoom: 14.0);
  bool isLoading = false;
  GeoCode geoCode = GeoCode(apiKey: geocoder_api_key);
  // address.Address currentUserAddress =
  //     address.Address(userAddress: [], latitude: 0.0, longitude: 0.0);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void loadDefaults() async {
    currentUserAddress.userAddress = await placemarkFromCoordinates(0.0, 0.0);
    // currentUserAddress.userAddress = await geoCode.reverseGeocoding(latitude: 0.0, longitude: 0.0);
  }

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
      currentPosition = LatLng(location.latitude, location.longitude);
      initialCameraPosition =
          CameraPosition(target: currentPosition, zoom: 14.0);
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
    List<Placemark> placeMark =
        await placemarkFromCoordinates(latitude, longitude);
    return placeMark;
    // final address =  await geoCode.reverseGeocoding(latitude: latitude, longitude: longitude);
    // return address;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Please select your location"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    _mapController.complete(controller);
                  });
                },
                initialCameraPosition: initialCameraPosition,
                markers: {
                  Marker(
                    markerId: const MarkerId("center_marker"),
                    position: currentPosition ?? initialCameraPosition.target,
                  ),
                },
                onCameraMove: (CameraPosition position) {
                  setState(() {
                    currentPosition = position.target;
                  });
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final double latitude = currentPosition.latitude;
          final double longitude = currentPosition.longitude;
          final address = await getAddressFromMarker(latitude, longitude);
          print("Current Address: $address");
          print("Latitude: $latitude, Longitude: $longitude");
          String newAddress =
              "${address.reversed.last.street != "" ? '${address.reversed.last.street}, ' : ""}${address.reversed.last.locality != "" ? '${address.reversed.last.locality}' : ""}";
          // String newAddress = "${address.streetAddress}, ${address.city}";
          setState(() {
            currentUserAddress.userAddress = address;
            currentUserAddress.latitude = latitude;
            currentUserAddress.longitude = longitude;
          });
          Navigator.pop(context, newAddress);
        },
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
