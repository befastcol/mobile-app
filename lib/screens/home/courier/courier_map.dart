import 'package:be_fast/screens/home/courier/providers/courier_map_provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_state_provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_stream_provider.dart';
import 'package:be_fast/screens/home/courier/widgets/service_found_card.dart';
import 'package:be_fast/shared/utils/determine_title.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CourierMap extends StatefulWidget {
  const CourierMap({super.key});

  @override
  State<CourierMap> createState() => _CourierMapState();
}

class _CourierMapState extends State<CourierMap> {
  late CourierMapProvider _courierMapProvider;
  late CourierStreamProvider _courierStreamProvider;
  late CourierStateProvider _courierStateProvider;

  @override
  void initState() {
    _courierMapProvider =
        Provider.of<CourierMapProvider>(context, listen: false);
    _courierStreamProvider =
        Provider.of<CourierStreamProvider>(context, listen: false);
    _courierStateProvider =
        Provider.of<CourierStateProvider>(context, listen: false);

    _courierMapProvider.initMap();
    _courierStreamProvider.initSocket();
    _courierStreamProvider.initCurrentLocation();
    _courierStreamProvider.initTimerStream(context);
    _courierStreamProvider.listenToDeliveryUpdates();
    _courierStateProvider.initCourier();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final courierStreamProvider = Provider.of<CourierStreamProvider>(context);
    final courierMapProvider = Provider.of<CourierMapProvider>(context);
    final courierStateProvider = Provider.of<CourierStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
          actions: <Widget>[
            Visibility(
              visible: courierStateProvider.courier?.status == 'available' ||
                  courierStateProvider.courier?.status == 'inactive',
              child: IconButton(
                icon: Icon(
                    courierStateProvider.isToggled
                        ? Icons.toggle_on
                        : Icons.toggle_off,
                    color: courierStateProvider.isToggled
                        ? Colors.teal
                        : Colors.blueGrey),
                onPressed: courierStateProvider.setToggled,
              ),
            ),
          ],
          title: Text(determineAppBarTitle(courierStateProvider.courier?.status,
              courierStreamProvider.serviceFound))),
      body: courierMapProvider.initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  initialCameraPosition:
                      courierMapProvider.initialCameraPosition!,
                  onMapCreated: (controller) =>
                      courierMapProvider.setGoogleMapController(controller),
                  markers: courierMapProvider.markers ?? {},
                ),
                const ServiceFoundCard()
              ],
            ),
    );
  }
}
