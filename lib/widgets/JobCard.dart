import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../core/constants/constants.dart';
import '../structure/Job.dart';
import '../structure/Order.dart';


class JobCard extends StatefulWidget {
  final Job job;
  const JobCard({super.key, required this.job});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserControllerProvider>(builder: (context, userControllerProvider, _){
      return FutureBuilder(future: userControllerProvider.getUserById(widget.job.jobRequestTo), builder: (context, snapshot){
        if(snapshot.hasError){
          Fluttertoast.showToast(msg: "Error fetching user data, contact developer");
          return Container();
        }
        else if (snapshot.hasData){
          final user = snapshot.data;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(kDefaultRounding)),
              child: Column(
                children: [
                  _shippingNumberRow(context, user.name, user.imageUrl),
                  RadialGradientDivider(),
                  _shippingInfo(context,
                      icon: Icons.email_outlined,
                      section1: "Email",
                      section2: "Request",
                      sectionContent1: user.email,
                      sectionContent2: "Verified"
                  ),
                  const SizedBox(height: 20),
                  _shippingInfo(context,
                      icon: Icons.work_outline,
                      section1: "Job Type",
                      section2: "Status",
                      sectionContent1: widget.job.jobType,
                      sectionContent2: widget.job.status,
                      haveStatusIcon: false),
                ],
              ),
            ),
          );
        }
        else{
          return const SizedBox(height:250, child:Center(child: CircularProgressIndicator()));
        }
      });
    },);
  }

  Widget _shippingNumberRow(context, String name, String imageUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        imageUrl == "NULL" ? const CircleAvatar(
          backgroundImage: AssetImage(
              "assets/images/avatars/user_02a.png"),
        ) : CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        const Gap(10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shippingSectionTitle(context, "Request To"),
            Text(name),
          ],
        ),
        // CustomArrowButton(onPressed: () {}),
      ],
    );
  }

  Widget _shippingInfo(
      context, {
        required IconData icon,
        required String section1,
        required String section2,
        required String sectionContent1,
        required String sectionContent2,
        bool haveStatusIcon = true,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(36)),
              width: 35,
              height: 35,
              child: Icon(icon),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shippingSectionTitle(context, section1),
                Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width / 2.5,
                      maxWidth: MediaQuery.of(context).size.width / 2.5),
                  child: Text(sectionContent1),
                )
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shippingSectionTitle(context, section2),
            Row(
              children: [
                haveStatusIcon
                    ? Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(36)),
                  width: 8,
                  height: 8,
                )
                    : Container(),
                haveStatusIcon ? const SizedBox(width: 5) : Container(),
                Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width / 4,
                      maxWidth: MediaQuery.of(context).size.width / 4),
                  child: Text(sectionContent2),
                )
              ],
            ),
          ],
        )
      ],
    );
  }

  Text shippingSectionTitle(context, String title) {
    return Text(
      title,
      style: poppins_bold.copyWith(
          color: Theme.of(context)
              .colorScheme
              .onPrimaryContainer
              .withOpacity(0.8)),
    );
  }

  Widget _receiverAndStatus(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(36)),
              width: 35,
              height: 35,
              child: Transform.scale(
                scale: 20 / 35,
                child: SvgPicture.asset(
                  "assets/images/svg/package_receive.svg",
                ),
              ),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                shippingSectionTitle(context, "Receiver"),
                Text(
                  "Bahria Town, Islamabad lahore",
                  style: poppins,
                )
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            shippingSectionTitle(context, "Time"),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(36)),
                  width: 8,
                  height: 8,
                ),
                const SizedBox(width: 5),
                Text(
                  "1 day - 2 day",
                  style: poppins,
                )
              ],
            ),
          ],
        )
      ],
    );
  }
}
