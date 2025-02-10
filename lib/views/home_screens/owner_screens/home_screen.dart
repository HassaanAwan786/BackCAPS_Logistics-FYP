import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/utils/utils.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../supporting/redirect_user.dart';

class LoadOwnerData extends StatefulWidget {
  const LoadOwnerData({super.key});

  @override
  State<LoadOwnerData> createState() => _LoadOwnerDataState();
}

class _LoadOwnerDataState extends State<LoadOwnerData> {
  bool isLoading = false;
  bool firstRun = true;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<UserControllerProvider>(builder: (context, userControllerProvider, _){
          return FutureBuilder(future: userControllerProvider.getUser(), builder: (context, snapshot){
            if(snapshot.hasError){
              Utils.showAlertPopup(context, "Something went wrong", "Sorry somehow we can't fetch the data");
              return Container();
            }
            else if(snapshot.hasData){
              final user = snapshot.data;
              if(user.role == "Role.Customer" || user.role == "Role.Driver"){
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(firstRun){
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const RedirectUser()),
                    );
                  }
                  firstRun = false;
                });
                return const Center(child: CircularProgressIndicator());
              }
              if(!user.verified){

              }
              return Container();
            }
            else{
              return const Center(child: CircularProgressIndicator());
            }
          });
        }),
        loadingBackgroundBlur(isLoading),
        loadingIndicator(context, isLoading),
      ],
    );
  }
}
