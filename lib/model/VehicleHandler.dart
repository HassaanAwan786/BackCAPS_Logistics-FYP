import 'dart:async';
import 'dart:collection';
import 'package:backcaps_logistics/structure/Customer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../structure/Driver.dart';
import '../structure/User.dart' as structure;
import '../structure/Vehicle.dart';
import 'database/DAO.dart';

class VehicleHandler implements DAO {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  final fireStorage = FirebaseStorage.instance;
  String databaseName = "Vehicles";
  late dynamic collection;

  VehicleHandler() {
    collection = fireStore.collection(databaseName);
  }

  @override
  Future<bool> create(vehicle) async {
    try {
      Map<String ,Object> dummyMap= {};
      await collection
          .doc(auth.currentUser!.uid)
          .collection(databaseName)
          .add(vehicle);
      //Now setting a dummy data to make the firestore collection readable
      await collection.doc(auth.currentUser!.uid).set(dummyMap);
      return true;
    } catch (exception) {
      print("Exception in adding vehicle to database: ${exception.toString()}");
      return false;
    }
  }

  @override
  Future<bool> delete(vehicleId) async {
    try{
      await collection.doc(auth.currentUser!.uid).collection(databaseName).doc(vehicleId).delete();
      return true;
    }catch(e){
      print("Error deleting vehicle in database: $e");
      return false;
    }
  }

  @override
  Future<List> getAll() async {
    List<Vehicle> vehicles = [];
    try {
      await collection
          .doc(auth.currentUser!.uid)
          .collection(databaseName)
          .get()
          .then((value) {
        for (var element in value.docs) {
          Vehicle vehicle = Vehicle.fromJson(element.data());
          vehicle.id = element.id;
          vehicles.add(vehicle);
        }
      });
      return vehicles;
    } catch (exception) {
      print(
          "Exception in getting all vehicles in database: ${exception.toString()}");
      return [];
    }
  }

  Future<bool> toggleAvailability(String id, bool state) async {
    try {
      await collection
          .doc(auth.currentUser!.uid)
          .collection(databaseName)
          .doc(id)
          .update({'isAvailable': state});
      return true;
    } catch (e) {
      print("Exception in toggling vehicle availability in database: $e");
      return false;
    }
  }

  @override
  Future get(String? title) async {
    try {
      DocumentSnapshot data = await collection.doc(auth.currentUser!.uid).get();
      final person = data.data() as Map<String, dynamic>;
      if (person['role'] == "Role.Customer") {
        return Customer.fromJson(person);
      } else if (person['role'] == "Role.Driver") {
        return Driver.fromJson(person);
      }
      return structure.User.fromJson(person);
    } catch (e) {
      print("Error getting user from database: $e");
      return structure.User.fromJson({});
    }
  }


  Future<bool> checkSameNumberPlate(numberPlate, Vehicle? comparisonVehicle) async {
    Completer<bool> checkingNumber = Completer();
    try {
      await collection.get().then((snapshot) async {
        for (var userDoc in snapshot.docs) {
          final userID = userDoc.id;
          QuerySnapshot vehicleSnapshot = await fireStore
              .collection(databaseName)
              .doc(userID)
              .collection(databaseName)
              .get();
          for (QueryDocumentSnapshot vehicleDoc in vehicleSnapshot.docs) {
            Map<String, dynamic> vehicle =
            vehicleDoc.data() as Map<String, dynamic>;
            if (numberPlate == vehicle['permit']['numberPlate']) {
              if(comparisonVehicle!=null){
                if(comparisonVehicle.id != vehicleDoc.id){
                  checkingNumber.complete(true);
                }
              }else{
                  checkingNumber.complete(true);
              }
            }
          }
        }
        checkingNumber.complete(false);
      });
      return await checkingNumber.future;
    } catch (e) {
      print("Error checking number plates in database: $e");
      return true;
    }
  }

  Future<String> uploadImage(image, String numberPlate) async {
    try {
      final path =
          "$databaseName/${auth.currentUser!.uid}/vehicles/$numberPlate.jpg";
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
  Future<bool> update(vehicle) async {
    try {
      await collection
            .doc(auth.currentUser!.uid)
            .collection(databaseName)
            .doc(vehicle.id)
            .update(vehicle.toJson());
      return true;
    } catch (e) {
      print("Exception in database while updating vehicle: $e");
      return false;
    }
  }
}
