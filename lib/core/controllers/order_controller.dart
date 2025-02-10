import 'package:backcaps_logistics/model/OrderHandler.dart';
import 'package:flutter/cupertino.dart';

import '../../structure/Order.dart';
import '../../structure/enums/OrderStatus.dart';

class OrderControllerProvider extends ChangeNotifier{
  final orderHandler = OrderHandler();
  String acceptedOrder = "NULL";
  // late dynamic databaseReference;
  List<String> rejectedOrders = [];
  List<dynamic> ordersList = []; //Specific to current customer user
  List<dynamic> everyOrderList = []; //Specific to drivers

  OrderControllerProvider() {
    // databaseReference = orderHandler.reference;
    loadOrdersIntoMemory();
  }

  Future<void> loadOrdersIntoMemory() async {
    ordersList = await getOrders();
    notifyListeners();
  }


  Future<bool> createOrder(dynamic order) async{
    try{
      await orderHandler.create(order);
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in creating order in controller: $e");
      return false;
    }
  }

  Future<bool> offerOrder(dynamic order) async{
    try{
      await orderHandler.offerOrder(order);
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in creating order in controller: $e");
      return false;
    }
  }

  Future<List<dynamic>> getOfferedOrders() async{
    try{
      final offeredOrders = await orderHandler.getOfferedOrders();
      notifyListeners();
      return offeredOrders;
    }catch(e){
      print("Exception in getting offered orders: $e");
      return [];
    }
  }

  Future<bool> havePendingOrders() async {
    try{
      return await orderHandler.havePendingOrders();
    }catch(e){
      print("Error checking pending orders: $e");
      return false;
    }
  }

  Future<bool> deleteOfferOrder(String orderId) async {
    try{
      await orderHandler.deleteOfferOrder(orderId);
      notifyListeners();
      return true;
    }catch(e){
      print("Exception while deleting offer order in controller: $e");
      return false;
    }
  }

  Future<List<dynamic>> getOrderHistory(String role) async {
    try{
      final orders = await orderHandler.getOrderHistory(role);
      notifyListeners();
      return orders;
    }catch(e){
      print("Exception in getting all orders in controller: $e");
      rethrow;
    }
  }
  Future<List<dynamic>> getPendingOrders() async {
    try{
      final list = await orderHandler.getOrdersByStatus("Pending");
      List<Order> pendingOrders = [];
      list.forEach((order) => !rejectedOrders.contains(order.orderId)? pendingOrders.add(order) : null);
      return pendingOrders;
    }catch(e){
      print("Exception in getting all orders in controller: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getInProcessOrders() async {
    try{
      final list = await orderHandler.getOrdersByStatus("InProcess");
      return list;
    }catch(e){
      print("Exception in getting all orders in controller: $e");
      rethrow;
    }
  }
  //Suspicious function// to be removed
  Future<List<dynamic>> getOrders() async {
    try{
      List<Order> orders = await orderHandler.get(null);
      notifyListeners();
      return orders;
    }catch(e){
      print("Exception in getting all orders in controller: $e");
      rethrow;
    }
  }

  Future<List<dynamic>> getDriverOrders() async {
    try{
      List<Order> orders = await orderHandler.getDriverOrders();
      notifyListeners();
      return orders;
    }catch(e){
      print("Exception in getting all orders in controller: $e");
      rethrow;
    }
  }
  Future<List<dynamic>> getCustomerOrders() async {
    try{
      List<Order> orders = await orderHandler.getCustomerOrders();
      notifyListeners();
      return orders;
    }catch(e){
      print("Exception in getting all orders in controller: $e");
      rethrow;
    }
  }

  Future<bool> updateSharedDelivery(orderId, bool isSharedDelivery) async {
    try{
      final result = await orderHandler.updateSharedDelivery(orderId, isSharedDelivery);
      notifyListeners();
      return result;
    }catch(e){
      print("Exception in controller while updating shared deliver: $e");
      return false;
    }
  }

  Future<bool> update(Order order) async {
    try{
      final result = await orderHandler.update(order);
      notifyListeners();
      return result;
    }catch(e){
      print("Exception while updating order in controller: $e");
      return false;
    }
  }

  Future<bool> deleteOrder(orderId) async{
    try{
      await orderHandler.delete(orderId);
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in deleting order in controller: $e");
      return false;
    }
  }
}