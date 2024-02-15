import 'package:be_fast/screens/home/home/cards/where_to_go.dart';
import 'package:be_fast/screens/home/home/widgets/drawer/my_drawer.dart';
import 'package:be_fast/providers/map.dart';
import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/home/widgets/searching_card/searching_card.dart';
import 'package:be_fast/screens/home/home/widgets/selection_card/selection_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userMapProvider = Provider.of<MapProvider>(context, listen: false);

    return FutureBuilder(
        future: Future.wait(
            [userProvider.initializeUser(), userMapProvider.initializeMap()]),
        builder: (context, snapshot) {
          return Consumer<MapProvider>(
              builder: (context, value, child) => Scaffold(
                    key: _scaffoldKey,
                    resizeToAvoidBottomInset: false,
                    drawer: const MyDrawer(),
                    floatingActionButton: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation.startTop,
                    body: value.initialCameraPosition == null
                        ? const Center(child: CircularProgressIndicator())
                        : Stack(
                            children: [
                              GoogleMap(
                                mapType: MapType.normal,
                                myLocationEnabled: true,
                                markers: value.markers!.length > 1
                                    ? value.markers!
                                    : {},
                                polylines: value.polylines,
                                initialCameraPosition:
                                    value.initialCameraPosition!,
                                myLocationButtonEnabled: false,
                                onMapCreated: (GoogleMapController controller) {
                                  if (!value.controller.isCompleted) {
                                    value.controller.complete(controller);
                                  }
                                },
                              ),
                              // const WhereToGoCard(),
                              Visibility(
                                visible: !value.isSearchingDeliveries,
                                child: const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: SelectionCard(),
                                ),
                              ),
                              Visibility(
                                visible: value.isSearchingDeliveries,
                                child: const Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: SearchingCard(),
                                ),
                              ),
                            ],
                          ),
                  ));
        });
  }
}
