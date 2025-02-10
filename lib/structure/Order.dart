import 'Package.dart';
import 'enums/OrderStatus.dart';
import 'Vehicle.dart';
import 'Address.dart';
import 'Location.dart';

class Order {
  late String orderId;
  late Address address;
  late DateTime estimatedTime;
  late DateTime orderTime;
  late OrderStatus status;
  late String vehicleId;
  late String vehicleCategory;
  late String driverId;
  late String organizationId;
  late String customerId;
  late String customerName;
  late String customerImage;
  late Package package;
  late int numberOfPackage;
  late bool sharedDelivery;
  late int price;

  Order({
    required this.package,
    required this.address,
    required this.estimatedTime,
    required this.orderTime,
    required this.status,
    required this.vehicleId,
    required this.vehicleCategory,
    required this.driverId,
    required this.organizationId,
    required this.customerId,
    required this.customerName,
    required this.customerImage,
    required this.numberOfPackage,
    required this.sharedDelivery,
    required this.price,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        numberOfPackage: json['numberOfPackage'] ?? 0,
        price: json['price'] ?? 0,
        package: Package.fromJson(json['package']),
        address: Address.fromJson(json['address']),
        estimatedTime: json['estimatedTime'].toDate() ?? DateTime.now(),
        orderTime: json['orderTime'].toDate() ?? DateTime.now(),
        status:
            json['status'] == "OrderStatus.InProgress"
            ? OrderStatus.InProcess
            : json['status'] == "OrderStatus.Shipped"
            ? OrderStatus.Shipped
            : json['status'] == "OrderStatus.Pending"
            ? OrderStatus.Pending
            : json['status'] == "OrderStatus.Approved"
            ? OrderStatus.Approved
            : json['status'] == "OrderStatus.Delivered"
            ? OrderStatus.Delivered
            : json['status'] == "OrderStatus.Rated"
            ? OrderStatus.Rated
            : json['status'] == "OrderStatus.WaitApproval"
            ? OrderStatus.WaitApproval
            : OrderStatus.InProcess,
        vehicleId: json['vehicleId'] ?? "NULL",
        vehicleCategory: json['vehicleCategory'] ?? "NULL",
        driverId: json['driverId'] ?? "NULL",
        organizationId: json['organizationId'] ?? "NULL",
        customerId: json['customerId'] ?? "NULL",
        customerName: json['customerName'] ?? "NULL",
        customerImage: json['customerImage'] ?? "NULL",
        sharedDelivery: json['sharedDelivery'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'price' :price,
        'package': package.toJson(),
        'address': address.toJson(),
        'estimatedTime': estimatedTime,
        'orderTime': orderTime,
        'status': status.toString(),
        'vehicleId': vehicleId,
        'vehicleCategory': vehicleCategory,
        'driverId': driverId,
        'organizationId': organizationId,
        'customerId': customerId,
        'customerName': customerName,
        'customerImage': customerImage,
        'numberOfPackage': numberOfPackage,
        'sharedDelivery': sharedDelivery,
      };
}
