import 'package:backcaps_logistics/structure/User.dart';
import 'Location.dart';

class Customer extends User {
  late String customerID;
  late int numberOfOrders;

  Customer(
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
      required this.customerID,
      required this.numberOfOrders});

  Customer.fromUser(User user, {
    required this.customerID,
    required this.numberOfOrders,
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
    imageUrl: user.imageUrl
  );

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
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
        customerID: json['customerID'] ?? "NULL",
        numberOfOrders: json['numberOfOrders'] ?? 0,
      );

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['customerID'] = customerID;
    data['numberOfOrders'] = numberOfOrders;
    return data;
  }
}
