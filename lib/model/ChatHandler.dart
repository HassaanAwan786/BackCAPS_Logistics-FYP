import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/state_manager.dart';
import '../structure/Chat.dart';
import 'database/DAO.dart';

class ChatHandler implements DAO {
  final auth = FirebaseAuth.instance;
  final fireStore = FirebaseFirestore.instance;
  String databaseName = "Chats";
  late dynamic collection;

  ChatHandler() {
    collection = fireStore.collection(databaseName);
  }

  @override
  Future<bool> create(chat) async {
    try {
      // await collection.doc(DateTime.now().millisecondsSinceEpoch.toString()).set(chat.toJson());
      Map<String ,Object> dummyMap= {};
      await collection
          .doc(chat.chatId)
          .collection("Messages")
          .doc(DateTime.now().millisecondsSinceEpoch.toString())
          .set(chat.toJson());
      await collection.doc(chat.chatId).set(dummyMap);
      return true;
    } catch (exception) {
      print("Exception in adding order to database: ${exception.toString()}");
      return false;
    }
  }

  @override
  Future<bool> delete(chat) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String? title) async {
    try {
      Map<String, String> docIds = {};
      final documents = await collection.get();
      documents.docs
          .forEach((doc) {
            final chatId = doc.id;
            final ids = chatId.split('_');
            if (ids.first == auth.currentUser!.uid) {
              docIds[ids.last] = chatId;
            } else if (ids.last== auth.currentUser!.uid) {
              docIds[ids.first] = chatId;
            }
          });
      return docIds;
    } catch (e) {
      print("Error fetching chat list in database :$e");
      return [];
    }
  }

  @override
  Future<List> getAll() async {
    throw UnimplementedError();
  }

  Future getMessages(String documentId) async {
    try{
      List<Chat> chats = [];
      final snapshot = await collection.doc(documentId).collection("Messages").get();
      snapshot.docs.forEach((element){
        final newChat = Chat.fromJson(element.data());
        newChat.chatId = element.id;
        newChat.isMe = auth.currentUser!.email == newChat.email;
        chats.add(newChat);
      });
      return chats;
    }catch(e){
      print("Error while fetching specific chat: $e");
      return [];
    }
  }

  @override
  Future<bool> update(chat) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
