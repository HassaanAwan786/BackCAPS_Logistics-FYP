import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../structure/Order.dart' as userOrder;
import '../structure/enums/OrderStatus.dart';
import 'database/DAO.dart';

class OrderHandler implements DAO{
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final fireStorage = FirebaseStorage.instance;
  String databaseName = "Orders";
  String offerDatabaseName = "Offer";
  late dynamic collection;

  OrderHandler(){
    collection = fireStore.collection(databaseName);
  }

  @override
  Future<bool> create(order) async {
    try {
      order.customerId = auth.currentUser!.uid;
      // await reference.child(order.orderId).set(order.toJson());
      await collection.doc(order.orderId).set(order.toJson());
      // Map<String ,Object> dummyMap= {};
      // await collection
      //     .doc(auth.currentUser!.uid)
      //     .collection(databaseName)
      //     .doc(order.orderId)
      //     .set(order.toJson());
      // //Now setting a dummy data to make the firestore collection readable
      // await collection.doc(auth.currentUser!.uid).set(dummyMap);
      return true;
    } catch (exception) {
      print("Exception in adding order to database: ${exception.toString()}");
      return false;
    }

  }
  Future<bool> offerOrder(order) async {
    try{
      order.driverId = auth.currentUser!.uid;
      await fireStore.collection(offerDatabaseName).doc(order.orderId).set(order.toJson());
      return true;
    }catch(e){
      print("Exception in offering order in database: $e");
      return false;
    }
  }

  @override
  Future<bool> delete(orderId) async {
    try{
      await collection.doc(orderId).delete();
      return true;
    }catch(e){
      print("Error deleting vehicle in database: $e");
      return false;
    }
  }

  //This is for 3 cases
  //1. If a driver is checking his own orders
  //2. If the order is still pending and no driver is assigned
  //3. If the driver is checking his own specific status of the order
  @override
  Future get(String? orderStatus) async {
    List<userOrder.Order> orders = [];
    try {
      await collection.get().then((snapshot) async {
        for(var orderDoc in snapshot.docs){
          final orderId = orderDoc.id;
          final order = orderDoc.data() as Map<String, dynamic>;
          final newOrder = userOrder.Order.fromJson(order);
          newOrder.orderId = orderId;
          orders.add(newOrder);
        }
      });
      // await collection
      //     .doc(auth.currentUser!.uid)
      //     .collection(databaseName)
      //     .get()
      //     .then((value) {
      //   for (var element in value.docs) {
      //     userOrder.Order order = userOrder.Order.fromJson(element.data());
      //     order.orderId = element.id;
      //     orders.add(order);
      //   }
      // });
      return orders;
    } catch (exception) {
      print(
          "Exception in getting orders in database: ${exception.toString()}");
      return [];
    }
  }


  Future<bool> havePendingOrders() async {
    try {
      List<userOrder.Order> orders = [];
      final list = await collection
          .where('status', whereIn: [OrderStatus.InProcess.toString(), OrderStatus.Shipped.toString()])
          .get();
      for (int index = 0; index < list.docs.length; index += 1) {
        final newOrder = userOrder.Order.fromJson(list.docs[index].data());
        newOrder.orderId = list.docs[index].id;
        orders.add(newOrder);
      }
      return orders.isNotEmpty;
    } catch (e) {
      print("Exception checking pending orders: $e");
      return false;
    }
  }


  Future getDriverOrders() async {
    try{
      List<userOrder.Order> orders = [];
      final list = await collection
          // .where('status', isEqualTo: "OrderStatus.$status")
          .where('driverId', isEqualTo: auth.currentUser!.uid)
          .get();
      for(int index = 0; index< list.docs!.length; index+=1){
        final newOrder = userOrder.Order.fromJson(list.docs[index].data());
        newOrder.orderId = list.docs[index].id;
        orders.add(newOrder);
      }
      return orders;
    }catch(e){
      print("Exception while getting relevant orders in database: $e");
      return [];
    }
  }
  Future getCustomerOrders() async {
    try{
      List<userOrder.Order> orders = [];
      final list = await collection
      // .where('status', isEqualTo: "OrderStatus.$status")
          .where('customerId', isEqualTo: auth.currentUser!.uid)
          .get();
      for(int index = 0; index< list.docs!.length; index+=1){
        final newOrder = userOrder.Order.fromJson(list.docs[index].data());
        newOrder.orderId = list.docs[index].id;
        orders.add(newOrder);
      }
      return orders;
    }catch(e){
      print("Exception while getting relevant orders in database: $e");
      return [];
    }
  }

  Future<List<dynamic>> getOfferedOrders() async {
    try{
      List<userOrder.Order> orders = [];
      // final list = await fireStore.collection(offerDatabaseName)
      //     .where('status', isEqualTo: "OrderStatus.Pending")
      //     .get();
      // for(int index = 0; index< list.docs!.length; index+=1){
      //   final newOrder = userOrder.Order.fromJson(list.docs[index].data());
      //   newOrder.orderId = list.docs[index].id;
      //   orders.add(newOrder);
      // }
      await fireStore.collection(offerDatabaseName).get().then((snapshot) async {
        for(var orderDoc in snapshot.docs){
          final orderId = orderDoc.id;
          // print(orderDoc.id.split("_")[1]);
          // if(orderDoc.id.split("_")[0] == orderId){
            // DocumentSnapshot orderSnapshot = await fireStore.collection(offerDatabaseName).doc(orderId).get();
            final order = orderDoc.data();
            final newOrder = userOrder.Order.fromJson(order);
            newOrder.orderId = orderId;
            orders.add(newOrder);
          // }
        }
      });
      return orders;
    }catch(e){
     print("Exception in getting offered orders in database: $e");
     return [];
    }
  }

  Future<bool> deleteOfferOrder(orderId) async {
    try{
      await fireStore.collection(offerDatabaseName).doc(orderId).delete();
      return true;
    }catch(e){
      print("Exception in deleting offer order in database: $e");
      return false;
      }
  }

  //In case if the owner of order is checking history
  @override
  Future<List> getAll() async {
    List<userOrder.Order> orders = [];
    try {
      await collection.get().then((snapshot) async {
        for(var orderDoc in snapshot.docs){
          final orderId = orderDoc.id;
          DocumentSnapshot orderSnapshot = await collection.doc(orderId).get();
          final order = orderSnapshot.data() as Map<String, dynamic>;
          if(order['customerId'] == auth.currentUser!.uid){
            final newOrder = userOrder.Order.fromJson(order);
            newOrder.orderId = orderId;
            orders.add(newOrder);
          }
        }
      });
      return orders;
    } catch (exception) {
      print(
          "Exception in getting all orders in database: ${exception.toString()}");
      return [];
    }
  }

  Future<List> getOrdersByStatus(String status) async {
    List<userOrder.Order> orders = [];
    try{
      final list = await collection
          .where('status', isEqualTo: "OrderStatus.$status")
          .get();
      for(int index = 0; index< list.docs!.length; index+=1){
        final newOrder = userOrder.Order.fromJson(list.docs[index].data());
        newOrder.orderId = list.docs[index].id;
            orders.add(newOrder);
      }
      return orders;
    } catch (exception) {
      print(
          "Exception in getting pending orders in database: ${exception.toString()}");
      return [];
    }
  }
  Future<List<userOrder.Order>> getOrderHistory(String role) async {
    List<userOrder.Order> orders = [];
    try {
      String comparisonId = (role == "Role.Driver") ? 'driverId' : 'customerId';
      QuerySnapshot snapshot = await collection.where(comparisonId, isEqualTo: auth.currentUser!.uid).get();

      for (var orderDoc in snapshot.docs) {
        final orderData = orderDoc.data() as Map<String, dynamic>;
        final newOrder = userOrder.Order.fromJson(orderData);
        newOrder.orderId = orderDoc.id;
        orders.add(newOrder);
      }

      return orders;
    } catch (exception) {
      print("Exception in getting all orders in database: ${exception.toString()}");
      return [];
    }
  }

  @override
  Future<bool> update(order) async {
    try{
      await collection.doc(order.orderId).update(order.toJson());
      return true;
    }catch(e){
      print("Exception while updating order in database: $e");
      return false;
    }
  }

  Future<bool> updateSharedDelivery(orderId, isSharedDelivery) async {
    try{
      await collection.doc(orderId).update({'sharedDelivery' : isSharedDelivery});
      return true;
    }catch(e){
      print("Exception while updating shared delivery in database: $e");
      return false;
    }
  }




}