import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../structure/GeoLocation.dart' as geolocation;

Future<LatLng> getCurrentLocation() async {
  try {

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
    final currentPosition = LatLng(location.latitude, location.longitude);
    return currentPosition;
  } catch (e) {
    print(e);
    rethrow;
  }
}
