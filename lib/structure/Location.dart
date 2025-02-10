import 'package:geocoding/geocoding.dart';

class Location{
  late double latitude;
  late double longitude;
  late String address;
  late List<Placemark> userAddress;

  Location({required this.latitude, required this.longitude, required this.address});

  factory Location.fromJson(Map<String, dynamic>json) => Location(
    latitude: json['latitude'] ?? 0.0,
    longitude: json['longitude'] ?? 0.0,
    address: json['address'] ?? "NULL"
  );

  Map<String, dynamic> toJson() => {
    'latitude' : latitude,
    'longitude' : longitude,
    'address' : address
  };
}