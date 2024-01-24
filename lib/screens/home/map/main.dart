import 'dart:async';
import 'package:be_fast/screens/home/map/components/location_selection_card.dart';
import 'package:be_fast/utils/location_utils.dart';
import 'package:be_fast/widgets/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(19.251918, -103.720911),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationHelper.determinePosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      final BitmapDescriptor blueMarker =
          BitmapDescriptor.defaultMarkerWithHue(200);

      setState(() {
        _initialCameraPosition =
            CameraPosition(target: currentLatLng, zoom: 14);
        _markers.add(Marker(
          markerId: const MarkerId('currentLocation'),
          position: currentLatLng,
          icon: blueMarker,
        ));
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 17));
    } catch (e) {
      debugPrint('Error al obtener ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: const MyDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: LocationSelectionCard(),
          ),
        ],
      ),
    );
  }
}
