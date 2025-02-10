import 'Driver.dart';
import 'Location.dart';

class Employee extends Driver{
  late String employeeID;
  late bool available;

  Employee({
    required super.name,
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
    required super.driverID,
    required super.license,
    required super.totalDeliveries,
    required super.totalVehicles,
    required super.verified,
    required this.employeeID,
    required this.available,
});
  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
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
    employeeID: json['employeeID'] ?? "NULL",
    available: json['available'] ?? false,
  );

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['employeeID'] = employeeID;
    data['available'] = available;
    return data;
  }
}