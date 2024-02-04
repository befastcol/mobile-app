import 'dart:async';
import 'package:be_fast/components/Drawer/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/screens/home/map/components/location_selection_card.dart';
import 'package:be_fast/utils/location_utils.dart';
import 'package:geolocator/geolocator.dart';
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
  CameraPosition? _initialCameraPosition;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await LocationHelper.determinePosition();
      _updateCameraPosition(position);
      _addCurrentLocationMarker(position);
    } catch (e) {
      debugPrint('Error al obtener ubicación: $e');
    }
  }

  void _updateCameraPosition(Position position) {
    final currentLatLng = LatLng(position.latitude, position.longitude);
    setState(() {
      _initialCameraPosition = CameraPosition(target: currentLatLng, zoom: 17);
    });
    _moveCamera(currentLatLng);
  }

  void _addCurrentLocationMarker(Position position) {
    final currentLatLng = LatLng(position.latitude, position.longitude);
    final BitmapDescriptor blueMarker =
        BitmapDescriptor.defaultMarkerWithHue(200);
    setState(() {
      _markers.add(Marker(
        markerId: const MarkerId('currentLocation'),
        position: currentLatLng,
        icon: blueMarker,
      ));
    });
  }

  Future<void> _moveCamera(LatLng target) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(target, 17));
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
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : _buildGoogleMap(),
    );
  }

  Widget _buildGoogleMap() {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialCameraPosition!,
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
    );
  }
}
