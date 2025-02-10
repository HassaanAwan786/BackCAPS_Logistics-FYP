import 'dart:async';
import 'package:backcaps_logistics/model/UserHandler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../views/supporting/otp_screen.dart';
import '../../structure/enums/Role.dart';

class UserControllerProvider extends ChangeNotifier {
  late dynamic user;
  late FirebaseAuth _auth;
  late Role? currentUserRole;
  final userHandler = UserHandler();

  UserControllerProvider() {
    _auth = userHandler.auth;
    currentUserRole = null;
    loadUserIntoMemory();
  }

  Future<void> loadUserIntoMemory() async {
    user = await getUser();
    notifyListeners();
  }

  Future<bool> createUser(dynamic user) async {
    try {
      userHandler.create(user.toJson());
      notifyListeners();
      return true;
    } catch (exception) {
      print(
          "Exception in user controller while creating user: ${exception.toString()}");
      return false;
    }
  }

  Future<dynamic> getUser() async {
    try {
      final user = await userHandler.get(null);
      notifyListeners();
      return user;
    } catch (exception) {
      print(
          "Exception in user controller while getting user: ${exception.toString()}");
      rethrow;
    }
  }
  Future<dynamic> getUserById(String userId) async {
    try {
      final user = await userHandler.get(userId);
      notifyListeners();
      return user;
    } catch (exception) {
      print(
          "Exception in user controller while getting user: ${exception.toString()}");
      rethrow;
    }
  }

  Future<bool> updateUser(dynamic user) async {
    try {
      userHandler.update(user);
      notifyListeners();
      return true;
    } catch (exception) {
      print(
          "Exception in user controller while updating user: ${exception.toString()}");
      return false;
    }
  }

  Future<bool> updateUserById(dynamic user, String id) async {
    try {
      userHandler.updateUserById(user, id);
      notifyListeners();
      return true;
    } catch (exception) {
      print(
          "Exception in user controller while updating user: ${exception.toString()}");
      return false;
    }
  }

  Future<bool> updateLocation(String address, double latitude, double longitude) async {
    try{
      await userHandler.updateLocation(address, latitude, longitude);
      return true;
    }catch(e){
      print("Exception while updating user location in controller: $e");
      return false;
    }
  }

  Future<String> uploadImage(image) async {
    try{
      final url = await userHandler.uploadImage(image);
      notifyListeners();
      print("Returning url: $url");
      return url;
    } catch(exception){
      print("Exception in uploadImage controller: $exception");
      return "NULL";
    }
  }

  /* -----------------------------------
  *  ----------Phone Verification---------
  *  ----------------------------------*/
  Future<bool> verifyPhoneNumber(
      String phoneNumber, BuildContext context) async {
    Completer<bool> verificationCompleter = Completer<bool>();
    bool verified = false;
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credentials) async {
            verified = true;
            verificationCompleter.complete(verified);
          },
          verificationFailed: (FirebaseAuthException ex) {
            verificationCompleter.completeError(ex);
          },
          codeSent: (String verificationId, int? resendToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                  phoneNumber: phoneNumber,
                ),
              ),
            ).then((otpVerified) {
              verified = otpVerified ?? false;
              verificationCompleter.complete(verified);
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {});
    } catch (e) {
      verificationCompleter.completeError(e);
    }
    print("Status verified of phone number: $verified");
    loadUserIntoMemory();
    return verificationCompleter.future;
  }


  Future<bool> updatePhone(String phoneNum) async {
    var status = await userHandler.updatePhoneNumber(phoneNum);
    notifyListeners();
    return status;
  }

  /* -----------------------------------
  *  ----------Authentication---------
  *  ----------------------------------*/
  bool isEmailVerified() {
    _auth.currentUser!.reload();
    bool emailVerified = _auth.currentUser!.emailVerified;
    notifyListeners();
    return emailVerified;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (exception) {
      print("Error signing in user: ${exception.toString()}");
      rethrow;
    }
  }

  Future<bool> signInWithUsername(String username, String password) async {
    try {
      QuerySnapshot userData = await userHandler.collection
          .where('username', isEqualTo: username)
          .get();
      if (userData.docs.isNotEmpty) {
        final userDoc = userData.docs.first;
        final email = userDoc['email'];
        return await signInWithEmail(email, password);
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkSameUsername(String username) async {
    try {
      QuerySnapshot userData = await userHandler.collection
          .where('username', isEqualTo: username)
          .get();
      if (userData.docs.isNotEmpty) {
        return false;
      }
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkSameCNIC(String cnic) async{
    try{
      QuerySnapshot cnicData = await userHandler.collection
          .where('cnic', isEqualTo: cnic)
          .get();
      if(cnicData.docs.isNotEmpty){
        return false;
      }
      return true;
    }catch(e){
      rethrow;
    }
  }

  Future<bool> sendEmailVerification(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (exception) {
      rethrow;
    }
  }

  String? getEmail() {
    return _auth.currentUser!.email;
  }

  Future<void> sendVerificationEmail() async {
    try {
      _auth.currentUser!.reload();
      await _auth.currentUser!.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<UserCredential> signupUser(
      {required String email, required String password}) async {
    return await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  FirebaseAuth get auth => _auth;

  void signOutUser() {
    _auth.signOut();
  }

  /*------------------------------------
  * ------------Role Handling-----------
  * -------------------------------------*/
  Future<bool> getRole() async {
    try {
      // print(_auth.currentUser!.email);
      QuerySnapshot user = await userHandler.collection
          .where('email', isEqualTo: _auth.currentUser!.email)
          .get();
      if (user.docs.isNotEmpty) {
        final userData = user.docs.first;
        final role = userData['role'];
        if ("Role.Customer" == role)
          currentUserRole = Role.Customer;
        else if ("Role.Driver" == role)
          currentUserRole = Role.Driver;
        else
          currentUserRole = Role.Owner;
      }
      return true;
    } catch (exception) {
      print("Error getting role: ${exception.toString()}");
      return false;
    }
  }

  Future<bool> updateRole(Role role) async {
    var status = await userHandler.updateRole(role.toString());
    user =await userHandler.get("");
    notifyListeners();
    return status;
  }

  Future<bool> incrementVehicleCount() async {
    try{
      await userHandler.incrementVehicleCount();
      notifyListeners();
      return true;
    }catch(e){
      print("Exception in incrementing vehicle count controller: $e");
      return false;
    }
  }
}
