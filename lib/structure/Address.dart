import 'Location.dart';
import 'package:open_route_service/open_route_service.dart';

class Address {
  late Location to;
  late Location from;
  late TimeDistanceMatrix timeDistanceMatrix;

  Address({required this.to, required this.from});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      to: Location.fromJson(json['to']),
      from: Location.fromJson(json['from']),
      // timeDistanceMatrix: TimeDistanceMatrix.fromJson(json['timeDistanceMatrix']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'to': to.toJson(),
      'from': from.toJson(),
      // 'timeDistanceMatrix': timeDistanceMatrix.toJson(),
    };
  }
}
