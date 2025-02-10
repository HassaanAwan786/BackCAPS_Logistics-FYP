import 'dart:async';

import 'package:backcaps_logistics/core/controllers/user_controller.dart';
import 'package:backcaps_logistics/core/controllers/vehicle_controller.dart';
import 'package:backcaps_logistics/core/services/current_location.dart';
import 'package:backcaps_logistics/views/chat_screen.dart';
import 'package:backcaps_logistics/views/home_screens/customer_screens/customer_home_screen.dart';
import 'package:backcaps_logistics/views/supporting/phone_verification_screen.dart';
import 'package:backcaps_logistics/views/supporting/redirect_user.dart';
import 'package:backcaps_logistics/views/track_order_screen.dart';
import 'package:backcaps_logistics/widgets/static_widgets.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../core/constants/constants.dart';
import '../../../core/utils/utils.dart';
import '../../../structure/enums/Role.dart';
import '../../../structure/theme/color_scheme.dart';
import '../../chat_main_screen.dart';
import '../../drawer_screen.dart';
import '../../notification_screen.dart';
import '../../profile_screen.dart';
import 'register_vehicle_screen.dart';
import 'components/vehicle_card.dart';

class LoadDriverData extends StatefulWidget {
  const LoadDriverData({super.key});

  @override
  State<LoadDriverData> createState() => _LoadDriverDataState();
}

class _LoadDriverDataState extends State<LoadDriverData> {
  bool firstRun = true;
  late dynamic user;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserControllerProvider>(
      builder: (context, userControllerProvider, _) {
        return FutureBuilder(
            future: userControllerProvider.getUser(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Utils.showAlertPopup(context, "Something went wrong",
                    "Could not establish the connection.");
              } else if (snapshot.hasData) {
                user = snapshot.data;
                if (user.role == "Role.Customer" || user.role == "Role.Owner") {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (firstRun) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (
                            context) => const RedirectUser()),
                      );
                    }
                    firstRun = false;
                  });
                  return Center(child: CircularProgressIndicator());
                }
                if (!user.phoneVerified) {
                  Fluttertoast.showToast(
                    msg: "Verify your phone number",
                    toastLength: Toast.LENGTH_SHORT,
                  );
                  return PhoneVerificationScreen(
                      phoneNumber: user.phoneNumber != "NULL"
                          ? user.phoneNumber
                          : null);
                }
                if (user.cnic == "NULL" ||
                    user.license == "NULL" ||
                    user.location.address == "NULL") {
                  return const ProfileScreen(isDriverRequesting: true);
                }
                //check if user have any vehicle registered or not
                if (user.totalVehicles == 0) {
                  return const AddVehicleScreen(isDriverRequesting: true);
                }
                return DriverHomeScreen(user: user);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            });
      },
    );
  }
}


class DriverHomeScreen extends StatefulWidget {
  final dynamic user;

  const DriverHomeScreen({super.key, this.user});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int selectedIndex = 0;
  final driverScreens = [];
  Widget? navBar;

  @override
  void initState() {
    super.initState();
    driverScreens.add(
        BuildDriverHomeScreen(scaffoldKey: _scaffoldKey));
    driverScreens.add(BuildVehicleScreen(scaffoldKey: _scaffoldKey));
    driverScreens.add(TrackOrderScreen());
    driverScreens.add(ChatMainScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // body: driverScreens[selectedIndex],
        body: driverScreens[selectedIndex],
        drawer: const CustomDrawer(),
        floatingActionButton: selectedIndex == 1
            ? FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                    const AddVehicleScreen(isDriverRequesting: false)));
          },
          label: const Text("Add Vehicle"),
          icon: const Icon(Icons.add),
        )
            : Container(),
        bottomNavigationBar: buildNavigationBar(context)
    );
  }

  NavigationBar buildNavigationBar(context) {
    // Color theme = MediaQuery
    //     .of(context)
    //     .platformBrightness == Brightness.light
    //     ? darkColorScheme.onPrimary
    //     : lightColorScheme.onPrimary;
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => setState(() => selectedIndex = index),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: "Home",
        ),
        NavigationDestination(
            icon: Icon(MdiIcons.truckOutline),
            selectedIcon: Icon(MdiIcons.truck),
            label: "Vehicle"),
        const NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: "Shipping"),
        const NavigationDestination(
          icon: Icon(Icons.chat_outlined),
          selectedIcon: Icon(Icons.chat),
          label: "Chat",
        ),
      ],
    );
  }
}

class BuildVehicleScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BuildVehicleScreen({super.key, required this.scaffoldKey});

  @override
  State<BuildVehicleScreen> createState() => _BuildVehicleScreenState();
}

class _BuildVehicleScreenState extends State<BuildVehicleScreen> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text("Vehicle Registration"),
        ),
        SliverToBoxAdapter(
          child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Consumer<VehicleControllerProvider>(
                  builder: (context, vehicleControllerProvider, _) {
                    return FutureBuilder(
                        future: vehicleControllerProvider.getAllVehicles(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Utils.showAlertPopup(
                                context,
                                "Something went wrong",
                                "Could not establish the connection.");
                          } else if (snapshot.hasData) {
                            final vehicles = snapshot.data;
                            return Column(
                              children: [
                                const Image(
                                  image: AssetImage(
                                      "assets/images/resources/vehicles.png"),
                                ),
                                Text("Total Vehicles: ${vehicles?.length}",
                                    style: poppins_bold),
                                const RadialGradientDivider(),
                                ...List.generate(
                                    vehicles!.length,
                                        (index) =>
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 10.0),
                                          child: VehicleCard(
                                              vehicle: vehicles[index], selectable: true,),
                                        )),
                                // VehicleCard(
                                //   vehicle: vehicles?[0],
                                //   isSelected: true,
                                // ),
                                const Gap(100),
                              ],
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        });
                  },
                )),
          ),
        ),
      ],
    );
  }
}

class BuildDriverHomeScreen extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const BuildDriverHomeScreen(
      {super.key, required this.scaffoldKey});

  @override
  State<BuildDriverHomeScreen> createState() => _BuildDriverHomeScreenState();
}

class _BuildDriverHomeScreenState extends State<BuildDriverHomeScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  late String _mapStyle;
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  double latitude = 0.0;
  double longitude = 0.0;
  LatLng currentPosition = initialLocation;
  CameraPosition initialCameraPosition =
  const CameraPosition(target: initialLocation, zoom: 14.0);

  @override
  void initState() {
    super.initState();
    addCustomIcon();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
  }

  void _goToCurrentLocation() {
    if (currentPosition != null) {
      if (_mapController.isCompleted) {
        _mapController.future.then((GoogleMapController controller) {
          controller
              .animateCamera(CameraUpdate.newLatLngZoom(currentPosition, 15));
        });
      } else {
        print("GoogleMapController is not yet available.");
      }
    }
  }

  void addCustomIcon() async {
    await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(1, 1)),
        "assets/icons/location_pin_drop.png")
        .then((value) =>
        setState(() {
          markerIcon = value;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserControllerProvider>(
        builder: (context, userControllerProvider, _) {
          return FutureBuilder(future: userControllerProvider.getUser(), builder: (context, snapshot){
            if(snapshot.hasError){
              Fluttertoast.showToast(msg: "Error fetching user data, Contact developer");
              return Container();
            }
            else if (snapshot.hasData){
              final user = snapshot.data;
              latitude = user.location.latitude;
              longitude = user.location.longitude;
              currentPosition = LatLng(latitude,longitude);
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    floating: true,
                    toolbarHeight: 60,
                    leadingWidth: 60,
                    leading: Ink(
                      child: InkWell(
                        onTap: () =>
                            setState(() => widget.scaffoldKey.currentState!.openDrawer()),
                        child: Container(
                          width: 53,
                          height: 53,
                          // margin: EdgeInsets.all(8.0),
                          padding: const EdgeInsets.only(left: 10.0),
                          child: user.imageUrl != "NULL"
                              ? CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(user.imageUrl),
                          )
                              : const CircleAvatar(
                            radius: 20,
                            backgroundImage:
                            AssetImage("assets/images/avatars/user_02a.png"),
                          ),
                        ),
                      ),
                    ),
                    centerTitle: false,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Your location",
                            style:
                            TextStyle(fontFamily: poppins.fontFamily, fontSize: 14)),
                        Text(
                          user.location.address,
                          style: TextStyle(
                              fontFamily: poppins.fontFamily,
                              fontSize: 14,
                              fontWeight: poppins_bold.fontWeight),
                        ),
                      ],
                    ),
                    // actions: [
                    //   Padding(
                    //     padding: const EdgeInsets.all(6.0),
                    //     child: IconButton.filledTonal(
                    //         onPressed: () {
                    //           Navigator.push(
                    //               context,
                    //               MaterialPageRoute(
                    //                   builder: (context) => const NotificationScreen()));
                    //         },
                    //         icon: const Icon(Icons.notifications_outlined)),
                    //   ),
                    // ],
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      child: Consumer<VehicleControllerProvider>(
                        builder: (context, vehicleControllerProvider, _) {
                          return FutureBuilder(
                              future: vehicleControllerProvider.getAllVehicles(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Utils.showAlertPopup(
                                      context,
                                      "Something went wrong",
                                      "Could not establish the connection.");
                                } else if (snapshot.hasData) {
                                  final vehicles = snapshot.data;
                                  initialCameraPosition = CameraPosition(
                                    target: LatLng(latitude, longitude),
                                    zoom: 16.0,
                                  );
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: MediaQuery.of(context).size.height / 3,
                                        child: GoogleMap(
                                          markers: {
                                            Marker(
                                              markerId: const MarkerId("marker1"),
                                              position: currentPosition,
                                              // icon: markerIcon
                                            ),
                                          },
                                          myLocationButtonEnabled: false,
                                          zoomControlsEnabled: false,
                                          initialCameraPosition: initialCameraPosition,
                                          onMapCreated:
                                              (GoogleMapController controller) async {
                                            setState(() {
                                              _mapController.complete(controller);
                                              // _mapController.future.setMapStyle(_mapStyle);
                                            });
                                            final currentLocation =
                                            await getCurrentLocation();
                                            _goToCurrentLocation();
                                            setState(() {
                                              latitude = currentLocation.latitude;
                                              longitude = currentLocation.longitude;
                                            });
                                          },
                                          onCameraIdle: (){
                                            _goToCurrentLocation();
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 10.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const FuturisticSectionTitle(
                                                title: "Set Availability"),
                                            ...List.generate(user.totalVehicles,
                                                    (index) {
                                                  final vehicle = vehicles?[index];
                                                  return Padding(
                                                    padding: const EdgeInsets.fromLTRB(
                                                        0, 0, 0, 10),
                                                    child: ListTile(
                                                      contentPadding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 10.0),
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(
                                                              kDefaultRounding)),
                                                      leading: Image(
                                                          image: NetworkImage(vehicle.image)),
                                                      tileColor: Theme.of(context)
                                                          .colorScheme
                                                          .surfaceVariant,
                                                      title: Text(
                                                        "${vehicle.model}",
                                                        style: poppins_bold,
                                                      ),
                                                      subtitle: Text(
                                                          "${vehicle.permit.numberPlate}"),
                                                      trailing: Switch(
                                                        value: vehicle.isAvailable,
                                                        onChanged: (value) async {
                                                          Provider.of<VehicleControllerProvider>(
                                                              context,
                                                              listen: false)
                                                              .toggleAvailability(vehicle.id,
                                                              !vehicle.isAvailable);
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: FuturisticSectionTitle(
                                            title: "Choose Your Option"),
                                      ),
                                      BuildOptionRow(role: user.role, userId: user.userId,),
                                      const Gap(50),
                                    ],
                                  );
                                } else {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              });
                        },
                      ),
                    ),
                  ),
                ],
              );
            }else{
              return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator()));
            }
          });
        });
  }
}
