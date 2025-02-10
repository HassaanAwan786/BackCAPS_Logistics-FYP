import 'package:backcaps_logistics/core/controllers/job_controller.dart';
import 'package:backcaps_logistics/core/controllers/organization_controller.dart';
import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/views/home_screens/owner_screens/OrganizationCard.dart';
import 'package:backcaps_logistics/widgets/custom_primary_button.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:provider/provider.dart';

import '../core/utils/utils.dart';
import '../structure/Job.dart';
import '../widgets/JobCard.dart';
import 'home_screens/driver_screens/components/vehicle_card.dart';

class FindJobScreen extends StatefulWidget {
  const FindJobScreen({super.key});

  @override
  State<FindJobScreen> createState() => _FindJobScreenState();
}

class _FindJobScreenState extends State<FindJobScreen> {
  bool applyForJob = false;
  int selectedVehicle = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Find Job"),
      ),
      body: Consumer<JobControllerProvider>(builder: (context, jobControllerProvider, _ ){
        return FutureBuilder(future: jobControllerProvider.getJobs(), builder: (context, snapshot){
          if(snapshot.hasError) {
            Fluttertoast.showToast(
                msg: "Error fetching jobs, contact developer.");
            return Container();
          }else if (snapshot.hasData){
            final jobs = snapshot.data;
            bool areJobsPending = false;
            for(Job job in jobs){
              if(job.status == "Pending" || job.status == "Accepted"){
                areJobsPending = true;
              }
            }
            if(areJobsPending){
              return Column(
                children: [
                  ...List.generate(jobs.length, (index) => JobCard(job: jobs[index]))
                ],
              );
            }
            return Center(
              child: !applyForJob? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 2,
                    child: LottieBuilder.asset("assets/animations/Empty_Box.json"),
                  ),
                  const Gap(40),
                  CustomGrandText(
                    text: "Oops!!! you have not applied",
                    fontSize: 20,
                  ),
                  const Gap(10),
                  CustomGrandText(
                    text: "Are you open to work?",
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                  ),
                  const Gap(10),
                  CustomPrimaryButton(onPressed: (){
                    setState(() {
                      applyForJob = true;
                    });
                  }, label: "Click Here", isBold: true),
                ],
              ): Consumer<VehicleControllerProvider>(
                  builder: (context, vehicleControllerProvider, _){
                    return FutureBuilder(future: vehicleControllerProvider.getAllVehicles(), builder: (context, snapshot){
                      if (snapshot.hasError) {
                        Fluttertoast.showToast(msg:
                        "Could not fetch vehicles record from database. Please contact developer.");
                        return Container();
                      } else if (snapshot.hasData) {
                        final vehicles = snapshot.data;
                        return Column(
                          children: [
                            SizedBox(
                              height: 250,
                              child: PageView(
                                onPageChanged: (index) {
                                  setState(() {
                                    selectedVehicle = index;
                                  });
                                },
                                children: [
                                  ...List.generate(vehicles!.length, (index) {
                                    // if(!vehicles[index].isAvailable) return Container();
                                    return Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child:
                                      VehicleCard(vehicle: vehicles[index], selectable: false,),
                                    );
                                  })
                                ],
                              ),
                            ),
                            PageViewDotIndicator(
                              currentItem: selectedVehicle,
                              count: vehicles.length,
                              unselectedColor:
                              Theme.of(context).colorScheme.surfaceVariant,
                              selectedColor:
                              Theme.of(context).colorScheme.primary,
                              size: const Size(12, 12),
                              unselectedSize: const Size(8, 8),
                            ),
                            const RadialGradientDivider(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Consumer<OrganizationControllerProvider>(builder: (context, organizationControllerProvider, _){
                                return FutureBuilder(future: organizationControllerProvider.getOrganizations(),
                                    builder: (context, snapshot){
                                      if(snapshot.hasError){
                                        Fluttertoast.showToast(msg: "Error fetching organizations, contact developer");
                                        return Container();
                                      }else if(snapshot.hasData){
                                        final organizations = snapshot.data;
                                        return Column(
                                          children: [
                                            ...List.generate(organizations.length, (index){
                                              return OrganizationCard(organization: organizations[index], isOrder: false);
                                            }),

                                          ],
                                        );
                                      }else{
                                        return const SizedBox(
                                          height: 250,
                                          child: Center(child: CircularProgressIndicator()),
                                        );
                                      }
                                    });
                              }),
                            )
                          ],
                        );
                      } else {
                        return const SizedBox(
                            height: 250,
                            child: Center(child: CircularProgressIndicator()));
                      }
                    });
                  }
              ),
            );
          }else {
            return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(),),);
          }
        });
      },)
    );
  }
}
