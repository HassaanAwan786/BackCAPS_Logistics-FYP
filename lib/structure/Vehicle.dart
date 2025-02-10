import 'package:backcaps_logistics/structure/VehiclePermit.dart';
import 'enums/VehicleCategory.dart';
import 'BoxContainer.dart';


class Vehicle {
  late String? id;
  late String image;
  late String category;
  late BoxContainer containerCapacity;
  late double engineHP;
  late double fuelCapacity;
  late String model;
  late int maxSpeed;
  late VehiclePermit permit;
  late bool isAvailable;

  Vehicle({
    this.id,
    required this.image,
    required this.category,
    required this.containerCapacity,
    required this.engineHP,
    required this.fuelCapacity,
    required this.model,
    required this.maxSpeed,
    required this.permit,
    required this.isAvailable,
  });
  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    image: json['image'] ?? "NULL",
    category: json['category'] ?? "NULL",
    containerCapacity: json['containerCapacity'] != null
      ? BoxContainer.fromJson(json['containerCapacity'])
      : BoxContainer(height: 0, maxWeight: 0,length: 0,width: 0),
    engineHP: json['engineHP'] ?? 0.0,
    fuelCapacity: json['fuelCapacity'] ?? 0.0,
    model: json['model'] ?? "NULL",
    maxSpeed: json['maxSpeed'] ?? 0,
    permit: json['permit'] != null
        ? VehiclePermit.fromJson(json['permit'])
        : VehiclePermit(permitNumber: "NULL",numberPlate: "NULL"),
      isAvailable: json['isAvailable'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'image' : image,
    'category' : category,
    'containerCapacity' : containerCapacity.toJson(),
    'engineHP' : engineHP,
    'fuelCapacity' : fuelCapacity,
    'model' : model,
    'maxSpeed' : maxSpeed,
    'permit' : permit.toJson(),
    'isAvailable' : isAvailable
  };
}
