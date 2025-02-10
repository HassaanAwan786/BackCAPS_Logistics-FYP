import 'package:backcaps_logistics/core/constants/constants.dart';
import 'package:backcaps_logistics/core/controllers/chat_controller.dart';
import 'package:backcaps_logistics/views/chat_screen.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:backcaps_logistics/widgets/custom_arrow_button.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../core/controllers/user_controller.dart';

class ChatMainScreen extends StatefulWidget {
  const ChatMainScreen({super.key});

  @override
  State<ChatMainScreen> createState() => _ChatMainScreenState();
}

class _ChatMainScreenState extends State<ChatMainScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RedirectUser()));
                },
                icon: const Icon(Icons.arrow_back_ios)),
            title: const Text('Chat'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Consumer<ChatControllerProvider>(
                builder: (context, chatControllerProvider, _) {
                  return FutureBuilder(
                      future: chatControllerProvider.getChats(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          Fluttertoast.showToast(
                              msg:
                                  "Error getting chats, please contact developer.");
                          return Container();
                        } else if (snapshot.hasData) {
                          isLoading = false;
                          final personIds = snapshot.data;
                          if(personIds.isEmpty){
                            return Column(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Lottie.asset("assets/animations/No_Notification.json"),
                                      Text("Oops!!! no chat found", style: poppins_bold.copyWith(
                                          fontSize: 17
                                      ),),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            children: [
                              ...List.generate(personIds.length, (index) {
                                return FutureBuilder(
                                    future: Provider.of<UserControllerProvider>(
                                            context)
                                        .getUserById(personIds.keys.elementAt(index)),
                                    builder: (context, snap_shot) {
                                      if (snap_shot.hasError) {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Cannot fetch user ${personIds.keys.elementAt(index)}, contact developer");
                                        return Container();
                                      } else if (snap_shot.hasData) {
                                        final user = snap_shot.data;
                                        Widget imageWidget;
                                        if(user.imageUrl == "NULL"){
                                          imageWidget = Image.asset("assets/images/avatars/user_02a.png");
                                        }
                                        else {
                                          imageWidget = Image.network(user.imageUrl);
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                                          child: ListTile(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatPerson: personIds[personIds.keys.elementAt(index)], user: user)));
                                            },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(kDefaultRounding)
                                            ),
                                            contentPadding: const EdgeInsets.all(9),
                                            tileColor: Theme.of(context).colorScheme.primaryContainer,
                                            title: Text(user.name, style: poppins),
                                            leading: ClipRRect(borderRadius: BorderRadius.circular(80), child: imageWidget),
                                            trailing: CustomArrowButton(),
                                          ),
                                        );
                                      } else {
                                        return const SizedBox(
                                          height: 45,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                    });
                              }),
                            ],
                          );
                          // return FutureBuilder(future: Provider.of<UserControllerProvider>(context).getUserById(chat), builder: builder);
                        } else {
                          isLoading = true;
                          return Container();
                        }
                      });
                },
              ),
            ),
          ),
        ),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading),
      ],
    );
  }
}
