import 'BoxContainer.dart';

class Package {
  late BoxContainer properties;
  late List<String> packageType;
  late String loadingType;

  Package(this.properties, this.packageType, this.loadingType);

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      BoxContainer.fromJson(json['properties']),
      List<String>.from(json['packageType']),
      json['loadingType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'properties': properties.toJson(),
      'packageType': packageType,
      'loadingType': loadingType,
    };
  }
}
