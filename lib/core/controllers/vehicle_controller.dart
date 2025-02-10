import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../../model/VehicleHandler.dart';
import '../../structure/Vehicle.dart';

class VehicleControllerProvider extends ChangeNotifier{
  late List<dynamic> vehicles;
  final vehicleHandler = VehicleHandler();

  VehicleControllerProvider(){
    loadVehiclesIntoMemory();
  }
  Future<void> loadVehiclesIntoMemory() async {
    vehicles = await getAllVehicles();
    notifyListeners();
  }

  Future<bool> createVehicle(dynamic vehicle) async{
    try{
      await vehicleHandler.create(vehicle.toJson());
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in creating vehicle in controller: $e");
      return false;
    }
  }

  Future<List<dynamic>> getAllVehicles() async {
    try{
      final vehicles = await vehicleHandler.getAll();
      notifyListeners();
      return vehicles;
    }catch(e){
      print("Exception in getting all vehicles in controller: $e");
      rethrow;
    }
  }

  Future<bool> updateVehicle(String? vehicleId, Vehicle newVehicle)async {
    try{
      newVehicle.id = vehicleId;
      await vehicleHandler.update(newVehicle);
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in updating vehicle in controller: $e");
      return false;
    }
  }

  Future<bool> deleteVehicle(vehicleId) async{
    try{
      await vehicleHandler.delete(vehicleId);
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in deleting vehicle in controller: $e");
      return false;
    }
  }
  /*----------------------------------
  ------Vehicle sub processes ---------
   -----------------------------------*/
  Future<String> uploadImage(image, String numberPlate) async {
    try{
      final url = await vehicleHandler.uploadImage(image, numberPlate);
      notifyListeners();
      return url;
    }catch(e){
      print("Exception in uploading vehicle in controller: $e");
      return "NULL";
    }
  }

  Future<bool> toggleAvailability(String id, bool state) async {
    try{
      final result = await vehicleHandler.toggleAvailability(id, state);
      notifyListeners();
      return result;
    }catch(e){
      print("Exception in toggling availability of vehicle in controller: $e");
      return false;
    }
  }

  /*---------------------------------------------
  * ------------Vehicle Authentication ----------
  * --------------------------------------------*/
  Future<bool> checkSameNumberPlate(numberPlate, Vehicle? vehicle) async {
    try{
      final numberPlateExists = await vehicleHandler.checkSameNumberPlate(numberPlate, vehicle);
      notifyListeners();
      return numberPlateExists;
    }catch(e){
      print("Exception while checking number plate in controller: $e");
      return true;
    }
  }
}