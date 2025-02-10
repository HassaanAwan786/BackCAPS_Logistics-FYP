import 'dart:async';

import 'package:backcaps_logistics/structure/Organization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../structure/Job.dart';
import '../structure/Order.dart' as userOrder;
import '../structure/enums/OrderStatus.dart';
import 'database/DAO.dart';

class JobHandler implements DAO{
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  String databaseName = "Jobs";
  late dynamic collection;

  JobHandler(){
    collection = fireStore.collection(databaseName);
  }

  @override
  Future<bool> create(job) async {
    try{
      await collection.add(job.toJson());
      return true;
    }catch(e){
      print("Error creating Job request: $e");
      return false;
    }
  }

  @override
  Future<bool> delete(job) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String? title) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<Job>> getAll() async {
    try {
      QuerySnapshot querySnapshot = await collection.where('jobRequest', isEqualTo: auth.currentUser!.uid).get();
      List<Job> jobs = querySnapshot.docs.map((doc) {
        return Job.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return jobs;
    } catch (e) {
      print('Error fetching jobs: $e');
      return [];
    }
  }


  @override
  Future<bool> update(organization) {
    // TODO: implement update
    throw UnimplementedError();
  }



}