import 'dart:async';

import 'package:backcaps_logistics/structure/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../structure/Order.dart' as userOrder;
import '../structure/enums/OrderStatus.dart';
import 'database/DAO.dart';

class OrganizationHandler implements DAO{
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  String databaseName = "Organizations";
  late dynamic collection;

  OrganizationHandler(){
    collection = fireStore.collection(databaseName);
  }

  @override
  Future<bool> create(organization) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(organization) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String? title) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List> getAll() async {
    try {
      QuerySnapshot querySnapshot = await collection.get();
      List<Organization> organizations = querySnapshot.docs.map((doc) {
        final newOrg = Organization.fromJson(doc.data() as Map<String, dynamic>);
        return newOrg;
      }).toList();
      return organizations;
    } catch (e) {
      print('Error fetching organizations: $e');
      return [];
    }
  }


  @override
  Future<bool> update(organization) {
    // TODO: implement update
    throw UnimplementedError();
  }



}