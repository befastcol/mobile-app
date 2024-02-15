import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/utils/bytes_from_asset.dart';
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
    _getDeliveryData();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _getDeliveryData() async {
    try {
      Delivery delivery =
          await DeliveriesAPI().getDeliveryById(deliveryId: widget.deliveryId);
      _setupMap(delivery);
    } catch (e) {
      debugPrint('Error fetching delivery data: $e');
    }
  }

  void _setupMap(Delivery delivery) async {
    final originLatLng =
        LatLng(delivery.origin.coordinates[0], delivery.origin.coordinates[1]);
    final destinationLatLng = LatLng(delivery.destination.coordinates[0],
        delivery.destination.coordinates[1]);
    final currentLocationLatLng =
        LatLng(delivery.currentLocation[0], delivery.currentLocation[1]);

    final motoIcon = await getBytesFromAsset('assets/moto_icon.png', 100);

    setState(() {
      _initialCameraPosition =
          CameraPosition(target: currentLocationLatLng, zoom: 18);
      _addMarker(
          'origin', originLatLng, BitmapDescriptor.defaultMarkerWithHue(200));
      _addMarker('destination', destinationLatLng,
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      _addMarker('currentLocation', currentLocationLatLng, motoIcon);
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

    if (_googleMapController != null) {
      _googleMapController!
          .moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: middlePoint,
        zoom: 12,
      )));
    }
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
