import 'package:backcaps_logistics/model/ChatHandler.dart';
import 'package:flutter/cupertino.dart';

import '../../structure/Chat.dart';

class ChatControllerProvider extends ChangeNotifier{
  ChatHandler chatHandler = ChatHandler();
  Future<bool> create(Chat chat) async{
    try{
      await chatHandler.create(chat);
      return true;
    }catch(e){
      print("Error creating chat in controller: $e");
      return false;
    }
  }
  Future getChats() async{
    try{
      final chats= await chatHandler.get(null);
      return chats;
    }catch(E){
      print("Error getting chats :$E");
      return [];
    }
  }

  Future getMessages(String documentId) async{
    try{
      return await chatHandler.getMessages(documentId);
    }catch(e){
      print("Error getting messages in controller: $e");
      return [];
    }
  }
}