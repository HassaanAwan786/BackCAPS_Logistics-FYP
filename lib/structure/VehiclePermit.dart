class VehiclePermit{
  late String numberPlate;
  late String permitNumber;

  VehiclePermit({required this.numberPlate,required this.permitNumber});

  factory VehiclePermit.fromJson(Map<String, dynamic> json) => VehiclePermit(
    numberPlate: json['numberPlate'] ?? 'NULL',
    permitNumber: json['permitNumber'] ?? 'NULL',
  );

  Map<String, dynamic> toJson() => {
    'numberPlate': numberPlate,
    'permitNumber': permitNumber,
  };


  @override
  String toString() {
    return 'VehiclePermit{numberPlate: $numberPlate, permitNumber: $permitNumber}';
  }
}