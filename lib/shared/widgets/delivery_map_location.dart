import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/shared/utils/icons_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DeliveryMapLocation extends StatefulWidget {
  final String deliveryId;

  const DeliveryMapLocation({Key? key, required this.deliveryId})
      : super(key: key);

  @override
  State<DeliveryMapLocation> createState() => _DeliveryMapLocationState();
}

class _DeliveryMapLocationState extends State<DeliveryMapLocation> {
  GoogleMapController? _googleMapController;
  CameraPosition? _initialCameraPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      DeliveryModel delivery =
          await DeliveriesAPI.getDeliveryById(deliveryId: widget.deliveryId);
      UserModel courier = await UsersAPI.getUser(userId: delivery.courier);
      LatLng currentLocationLatLng = LatLng(
          courier.currentLocation?.coordinates[1] ?? 0,
          courier.currentLocation?.coordinates[0] ?? 0);
      _setupMap(delivery, courier, currentLocationLatLng);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void _setupMap(DeliveryModel delivery, UserModel courier,
      LatLng currentLocationLatLng) async {
    final originLatLng =
        LatLng(delivery.origin.coordinates[1], delivery.origin.coordinates[0]);
    final destinationLatLng = LatLng(delivery.destination.coordinates[1],
        delivery.destination.coordinates[0]);

    // Determinar el ícono en base al tipo de ehículo del courier
    BitmapDescriptor vehicleIcon;
    if (courier.vehicle == "motorcycle") {
      vehicleIcon = await getBytesFromAsset('assets/images/moto_icon.png', 100);
    } else if (courier.vehicle == "car") {
      vehicleIcon = await getBytesFromAsset('assets/images/car_icon.png', 100);
    } else {
      vehicleIcon = await getBytesFromAsset('assets/images/moto_icon.png', 100);
    }

    setState(() {
      _initialCameraPosition =
          CameraPosition(target: currentLocationLatLng, zoom: 18);
      _addMarker(
          'origin', originLatLng, BitmapDescriptor.defaultMarkerWithHue(200));
      _addMarker('destination', destinationLatLng,
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      _addMarker('currentLocation', currentLocationLatLng, vehicleIcon);
      _updateCameraBounds(currentLocationLatLng, destinationLatLng);
    });
  }

  void _addMarker(String id, LatLng latLng, BitmapDescriptor icon) {
    _markers.add(Marker(markerId: MarkerId(id), position: latLng, icon: icon));
  }

  void _updateCameraBounds(
      LatLng currentLocationLatLng, LatLng destinationLatLng) {
    double middleLat =
        (currentLocationLatLng.latitude + destinationLatLng.latitude) / 2;
    double middleLng =
        (currentLocationLatLng.longitude + destinationLatLng.longitude) / 2;
    LatLng middlePoint = LatLng(middleLat, middleLng);

    _googleMapController
        ?.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: middlePoint,
      zoom: 12,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('En camino...')),
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              initialCameraPosition: _initialCameraPosition!,
              markers: _markers,
              onMapCreated: (controller) => _googleMapController = controller,
            ),
    );
  }
}
