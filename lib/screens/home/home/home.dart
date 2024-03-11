import 'package:be_fast/providers/delivery_provider.dart';
import 'package:be_fast/screens/home/home/widgets/loading_skeleton.dart';
import 'package:be_fast/screens/home/home/widgets/looking_for_couriers_card.dart';
import 'package:be_fast/screens/home/home/widgets/service_request_card.dart';
import 'package:be_fast/screens/home/home/widgets/where_to_go_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_map_provider.dart';
import 'widgets/my_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserMapProvider, DeliveryProvider>(
        builder: (context, mapState, deliveryState, child) => Scaffold(
            key: _scaffoldKey,
            resizeToAvoidBottomInset: false,
            drawer: const MyDrawer(),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.white,
              child: const Icon(Icons.menu),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            body: mapState.initialCameraPosition == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(children: [
                    GoogleMap(
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      markers: mapState.markers,
                      polylines: mapState.polylines,
                      initialCameraPosition: mapState.initialCameraPosition!,
                      myLocationButtonEnabled: false,
                      onMapCreated: (GoogleMapController controller) {
                        if (!mapState.controller.isCompleted) {
                          mapState.controller.complete(controller);
                        }
                      },
                    ),
                    const WhereToGoCard(),
                    const LoadingSkeleton(),
                    const ServiceRequestCard(),

                    //We don't want to call its initState until id is not empty
                    Visibility(
                        visible: deliveryState.id.isNotEmpty,
                        child: const LookingForCouriersCard())
                  ])));
  }
}
