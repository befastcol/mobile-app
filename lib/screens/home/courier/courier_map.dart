import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_map_provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_stream_provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_state_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:be_fast/screens/home/courier/widgets/service_accepted_card.dart';
import 'package:be_fast/screens/home/courier/widgets/service_found_card.dart';
import 'package:be_fast/shared/utils/determine_title.dart';

class CourierMap extends StatefulWidget {
  const CourierMap({super.key});

  @override
  CourierMapState createState() => CourierMapState();
}

class CourierMapState extends State<CourierMap> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourierMapProvider()),
        ChangeNotifierProvider(
          create: (context) => CourierStreamProvider(
            Provider.of<CourierMapProvider>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(create: (_) => CourierStateProvider()),
      ],
      child: const CourierMapBody(),
    );
  }
}

class CourierMapBody extends StatefulWidget {
  const CourierMapBody({super.key});

  @override
  CourierMapBodyState createState() => CourierMapBodyState();
}

class CourierMapBodyState extends State<CourierMapBody> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<CourierMapProvider, CourierStreamProvider,
        CourierStateProvider>(builder: (context, map, stream, state, child) {
      int timeLeft = stream.deadline != null
          ? stream.deadline!.difference(DateTime.now()).inSeconds
          : 0;

      return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            Visibility(
              visible: (state.courier?.status == 'available' ||
                      state.courier?.status == 'inactive') &&
                  !stream.serviceFound &&
                  !stream.serviceAccepted,
              child: IconButton(
                iconSize: 40,
                icon: Icon(
                  state.isToggled ? Icons.toggle_on : Icons.toggle_off,
                  color: state.isToggled ? Colors.teal : Colors.blueGrey,
                ),
                onPressed: state.setToggled,
              ),
            ),
          ],
          title: Text(determineAppBarTitle(state.courier?.status,
              stream.serviceFound, stream.serviceAccepted, timeLeft)),
        ),
        body: map.initialCameraPosition == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GoogleMap(
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    polylines: map.polylines,
                    markers: map.markers,
                    initialCameraPosition: map.initialCameraPosition!,
                    onMapCreated: (controller) =>
                        map.setGoogleMapController(controller),
                  ),
                  ServiceFoundCard(timeLeft: timeLeft),
                  const ServiceAcceptedCard(),
                ],
              ),
      );
    });
  }
}
