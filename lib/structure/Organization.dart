class Organization {
  late int vehiclesOnRoute;
  late int availableVehicles;
  late int delayedDeliveries;
  late String description;
  late String name;
  late String email;
  late int numberOfDrivers;
  late int numberOfVehicles;
  late int onTimeDeliveries;
  late String organizationId;

  Organization({
    required this.vehiclesOnRoute,
    required this.availableVehicles,
    required this.delayedDeliveries,
    required this.description,
    required this.name,
    required this.email,
    required this.numberOfDrivers,
    required this.numberOfVehicles,
    required this.onTimeDeliveries,
    required this.organizationId,
  });

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    vehiclesOnRoute: json['VehiclesOnRoute'] ?? 0,
    availableVehicles: json['AvailableVehicle'] ?? 0,
    delayedDeliveries: json['DelayedDeliveries'] ?? 0,
    description: json['Description'] ?? 'NULL',
    name: json['Name'] ?? 'NULL',
    email: json['Email'] ?? 'NULL',
    numberOfDrivers: json['NumberofDrivers'] ?? 0,
    numberOfVehicles: json['NumberofVehicle'] ?? 0,
    onTimeDeliveries: json['OnTimeDelivery'] ?? 0,
    organizationId: json['OrganizationId'] ?? 'NULL',
  );

  Map<String, dynamic> toJson() => {
    'VehiclesOnRoute': vehiclesOnRoute,
    'AvailableVehicle': availableVehicles,
    'DelayedDeliveries': delayedDeliveries,
    'Description': description,
    'Name': name,
    'Email': email,
    'NumberofDrivers': numberOfDrivers,
    'NumberofVehicle': numberOfVehicles,
    'OnTimeDelivery': onTimeDeliveries,
    'OrganizationId': organizationId,
  };
}
