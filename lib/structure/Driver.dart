import 'package:backcaps_logistics/structure/User.dart';
import 'Location.dart';

class Driver extends User {
  late String driverID;
  late String license;
  late int totalDeliveries;
  late int totalVehicles;
  late bool verified;

  Driver(
      {required super.name,
        required super.username,
        required super.email,
        required super.phoneNumber,
        required super.phoneVerified,
        required super.registrationTime,
        required super.cnic,
        required super.rating,
        required super.location,
        required super.role,
        required super.imageUrl,
        required this.driverID,
        required this.license,
        required this.totalDeliveries,
        required this.totalVehicles,
        required this.verified,
      });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    name: json['name'] ?? "NULL",
    username: json['username'] ?? "NULL",
    email: json['email'] ?? "NULL",
    phoneNumber: json['phoneNumber'] ?? "NULL",
    phoneVerified: json['phoneVerified'] ?? false,
    cnic: json['cnic'] ?? "NULL",
    rating: json['rating'] ?? 0.0,
    registrationTime: json['registrationTime'] ?? DateTime.now(),
    location: Location.fromJson(json['location']),
    role: json['role'] ?? "NULL",
    imageUrl: json['imageUrl'] ?? "NULL",
    driverID: json['driverID'] ?? "NULL",
    license: json['license'] ?? "NULL",
    totalDeliveries: json['totalDeliveries'] ?? 0,
    totalVehicles: json['totalVehicles'] ?? 0,
    verified: json['verified'] ?? false,
  );
  Driver.fromUser(User user, {
    required this.driverID,
    required this.license,
    required this.totalDeliveries,
    required this.totalVehicles,
    required this.verified,
  }) : super(
    name: user.name,
    username: user.username,
    email: user.email,
    phoneNumber: user.phoneNumber,
    phoneVerified: user.phoneVerified,
    registrationTime: user.registrationTime,
    cnic: user.cnic,
    rating: user.rating,
    location: user.location,
    role: user.role,
    imageUrl: user.imageUrl,
  );
  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['driverID'] = driverID;
    data['license'] = license;
    data['totalDeliveries'] = totalDeliveries;
    data['totalVehicles'] = totalVehicles;
    data['verified'] = verified;
    return data;
  }
}
