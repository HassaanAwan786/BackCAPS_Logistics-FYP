import 'package:backcaps_logistics/structure/User.dart';
import 'Location.dart';

class Owner extends User {
  late double earning;
  late String ownerID;
  late double profit;
  late bool verified;

  Owner(
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
        required this.earning,
        required this.ownerID,
        required this.profit,
        required this.verified,
      });

  factory Owner.fromJson(Map<String, dynamic> json) => Owner(
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
    earning: json['earning'] ?? 0.0,
    ownerID: json['ownerID'] ?? "NULL",
    profit: json['profit'] ?? 0.0,
    verified: json['verified'] ?? false,
  );

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = super.toJson();
    data['ownerID'] = ownerID;
    data['earning'] = earning;
    data['profit'] = profit;
    data['verified'] = verified;
    return data;
  }
}
