import 'package:backcaps_logistics/model/ChatHandler.dart';
import 'package:backcaps_logistics/model/OrganizationHandler.dart';
import 'package:flutter/cupertino.dart';

import '../../structure/Chat.dart';

class OrganizationControllerProvider extends ChangeNotifier{
  OrganizationHandler organizationHandler = OrganizationHandler();

  Future getOrganizations() async{
    try{
      return await organizationHandler.getAll();
    }catch(E){
      print("Error getting organizations: $E");
      return [];
    }
  }

}