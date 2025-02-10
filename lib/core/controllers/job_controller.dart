import 'package:backcaps_logistics/model/ChatHandler.dart';
import 'package:backcaps_logistics/model/JobHandler.dart';
import 'package:backcaps_logistics/model/OrganizationHandler.dart';
import 'package:flutter/cupertino.dart';

class JobControllerProvider extends ChangeNotifier{
  JobHandler jobHandler = JobHandler();

  Future<bool> createJob(job) async {
    try{
      return await jobHandler.create(job);
    }catch(e){
      rethrow;
    }
  }

  Future getJobs() async{
    try{
      return await jobHandler.getAll();
    }catch(E){
      print("Error getting organizations: $E");
      return [];
    }
  }

}