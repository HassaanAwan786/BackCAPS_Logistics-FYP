import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Location.dart';

class User {
  late String userId;
  late String name;
  late String username;
  late String email;
  late String _password;
  late String phoneNumber;
  late bool phoneVerified;
  late String registrationTime;
  late String cnic;
  late double rating;
  late Location location;
  late String role;
  late String imageUrl;

  User({
    required this.name,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.phoneVerified,
    required this.registrationTime,
    required this.cnic,
    required this.rating,
    required this.location,
    required this.role,
    required this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    name: json['name'] ?? "NULL",
    username: json['username'] ?? "NULL",
    email: json['email'] ?? "NULL",
    phoneNumber: json['phoneNumber'] ?? "NULL",
    phoneVerified: json['phoneVerified'] ?? false,
    registrationTime: json['registrationTime'] ?? DateTime.now().toString(),
    cnic: json['cnic'] ?? "NULL",
    rating: json['rating'] ?? 0.0,
    location: json['location'] != null
        ? Location.fromJson(json['location'])
        : Location(latitude: 0.0, longitude: 0.0, address: "NULL"),
    role: json['role'] ?? "NULL",
    imageUrl: json['imageUrl'] ?? "NULL"
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'email': email,
    'phoneNumber': phoneNumber,
    'phoneVerified': phoneVerified,
    'registrationTime': registrationTime,
    'cnic': cnic,
    'rating': rating,
    'location' : location.toJson(),
    'role' : role,
    'imageUrl': imageUrl
  };


}


// Person
// + name: String
// + username: String
// + email: String
// - password: String
// + phone: String
// + phoneVerified: boolean
// + registrationTime: int
// + nic: String
// + rating: Rating
// + address: Location