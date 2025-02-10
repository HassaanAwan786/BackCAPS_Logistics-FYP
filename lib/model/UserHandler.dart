import 'package:backcaps_logistics/structure/Customer.dart';
import 'package:backcaps_logistics/structure/Owner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../structure/Driver.dart';
import '../structure/User.dart' as structure;
import 'database/DAO.dart';

class UserHandler implements DAO {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final fireStorage = FirebaseStorage.instance;
  String databaseName = "Users";
  late dynamic collection;

  UserHandler() {
    collection = fireStore.collection(databaseName);
  }

  @override
  Future<bool> create(user) async {
    try {
      await collection.doc(auth.currentUser!.uid).set(user);
      return true;
    } catch (exception) {
      print("Exception in creating user database: ${exception.toString()}");
      return false;
    }
  }

  @override
  Future<bool> delete(user) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  Future get(String? id) async {
    try {
      DocumentSnapshot data = id == null
          ? await collection.doc(auth.currentUser!.uid).get()
          : await collection.doc(id).get();
      // final data = await collection.doc(auth.currentUser!.uid).get();
      // print(data.data());
      final person = data.data() as Map<String, dynamic>;
      if (person['role'] == "Role.Customer") {
        final customer = Customer.fromJson(person);
        customer.userId = id ?? auth.currentUser!.uid;
        return customer;
      } else if (person['role'] == "Role.Driver") {
        final driver = Driver.fromJson(person);
        driver.userId = id ?? auth.currentUser!.uid;
        return driver;
      } else if (person['role'] == "Role.Owner") {
        final owner = Owner.fromJson(person);
        owner.ownerID = id ?? auth.currentUser!.uid;
        return owner;
      }
      final user = structure.User.fromJson(person);
      user.userId = id ?? auth.currentUser!.uid;
      return user;
    } catch (e) {
      print("Error getting user from database: $e");
      return structure.User.fromJson({});
    }
  }

  Future<bool> updatePhoneNumber(String number) async {
    try {
      await collection
          .doc(auth.currentUser!.uid)
          .update({'phoneNumber': number, 'phoneVerified': true});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<String> uploadImage(image) async {
    try {
      final path = "$databaseName/${auth.currentUser!.uid}/profile_image.jpg";
      print("Getting path: $path");
      final reference = fireStorage.ref().child(path);
      print("Getting reference: $reference");
      UploadTask? uploadTask = reference.putFile(image);
      print("Uploading task: ${uploadTask.snapshot}");
      final snapshot = await uploadTask.whenComplete(() {});
      print("Snapshot: $snapshot");
      final urlDownload = await snapshot.ref.getDownloadURL();
      print("URL: $urlDownload");
      return urlDownload;
    } catch (e) {
      print("Exception in database while uploading image: $e");
      return "NULL";
    }
  }

  @override
  Future<bool> update(user) async {
    try {
      await collection.doc(auth.currentUser!.uid).update(user);
      return true;
    } catch (e) {
      print("Exception in database while updating user: $e");
      return false;
    }
  }

  Future<bool> updateUserById(user, id) async {
    try {
      await collection.doc(id).update(user);
      return true;
    } catch (e) {
      print("Exception in database while updating user: $e");
      return false;
    }
  }

  Future<bool> updateRole(role) async {
    try {
      await collection.doc(auth.currentUser!.uid).update({'role': role});
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateLocation(String address, double latitude, double longitude) async {
    try {
      await collection.doc(auth.currentUser!.uid).update({
        'location': {'latitude': latitude, 'longitude': longitude, 'address': address}
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> incrementVehicleCount() async {
    try {
      final user = await get(null);
      await collection
          .doc(auth.currentUser!.uid)
          .update({'totalVehicles': user.totalVehicles + 1});
      return true;
    } catch (e) {
      print("Exception in incrementing vehicle count: $e");
      return false;
    }
  }
}
