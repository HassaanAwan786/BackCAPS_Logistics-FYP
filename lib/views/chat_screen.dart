import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/controllers/chat_controller.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:backcaps_logistics/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../core/utils/text_handler.dart';
import '../structure/Chat.dart';

class ChatScreen extends StatefulWidget {
  final String chatPerson;
  final dynamic user;

  static String id = "Chat_Screen";

  const ChatScreen({super.key, required this.chatPerson, required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final textController = TextFieldController();
  late User loggedInUser;
  late String textMessage;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        print(user.email);
      }
    } catch (e) {
      print(e);
    }
  }

  List<dynamic> bubbleSortReverse(List<dynamic> arr) {
    List<dynamic> sortedList = List.of(arr);
    sortedList.sort((a, b) => b.id.compareTo(a.id));
    return sortedList;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user.name),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('Chats')
                  .doc(widget.chatPerson)
                  .collection('Messages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  Fluttertoast.showToast(
                      msg:
                      "Something went wrong while fetching data, contact developer.");
                  return Container();
                } else if (snapshot.hasData) {
                  final messageList = snapshot.data!.docs;
                  List messages = bubbleSortReverse(messageList);
                  List<MessageBubble> messageWidgets = [];
                  for (var message in messages) {
                    if (message['text'] != "NULL") {
                      final text = message['text'];
                      final sender = message['email'];
                      final isMe = message['email'] == loggedInUser.email;
                      final widget = MessageBubble(
                        text: text,
                        sender: sender,
                        isMe: isMe,
                      );
                      messageWidgets.add(widget);
                    }
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      children: messageWidgets,
                    ),
                  );
                } else {
                  return const SizedBox(
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ),
            const Gap(20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: CustomTextField(
                        textFieldController: textController,
                        label: "Enter your message",
                        onChanged: (value) {
                          setState(() {
                            textMessage = value;
                          });
                        },
                        icon: Icons.textsms_outlined,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () {
                      textController.controller.clear();
                      if (textMessage.isNotEmpty) {
                        Chat chat = Chat(
                          text: textMessage,
                          email: loggedInUser.email ?? "NULL",
                        );
                        chat.chatId = widget.chatPerson;
                        Provider.of<ChatControllerProvider>(context, listen: false).create(chat);
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.send),
                    padding: const EdgeInsets.all(20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble(
      {super.key,
        required this.text,
        required this.sender,
        required this.isMe});

  final String text;
  final String sender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
          Material(
            elevation: 5,
            color: isMe
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
            borderRadius: isMe
                ? const BorderRadius.only(
                topLeft: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0))
                : const BorderRadius.only(
                topRight: Radius.circular(30.0),
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0)),
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Text(
                text,
                style: TextStyle(
                  color: isMe
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
