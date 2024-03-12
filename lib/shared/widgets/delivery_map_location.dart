import 'package:be_fast/api/deliveries.dart';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/delivery.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/shared/utils/icons_helper.dart';
import 'package:be_fast/shared/utils/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'delivery_details_card.dart';

class DeliveryMapLocation extends StatefulWidget {
  final String deliveryId;

  const DeliveryMapLocation({Key? key, required this.deliveryId})
      : super(key: key);

  @override
  State<DeliveryMapLocation> createState() => _DeliveryMapLocationState();
}

class _DeliveryMapLocationState extends State<DeliveryMapLocation> {
  final SocketService _socketService = SocketService();
  BitmapDescriptor? vehicleIcon;
  DeliveryModel? _delivery;
  UserModel? _courier;
  GoogleMapController? _googleMapController;
  CameraPosition? _initialCameraPosition;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    _socketService.initSocket();
    _initDelivery();
    _listenToCourierLocationChanges();

    super.initState();
  }

  @override
  void dispose() {
    debugPrint("delivery map location disposed");
    _socketService.clearListeners();
    _socketService.disconnect();
    _googleMapController?.dispose();
    super.dispose();
  }

  Future<void> _initDelivery() async {
    try {
      DeliveryModel delivery =
          await DeliveriesAPI.getDeliveryById(deliveryId: widget.deliveryId);
      setState(() => _delivery = delivery);
      UserModel courier = await UsersAPI.getUser(userId: delivery.courier);
      setState(() => _courier = courier);

      LatLng courierLocation = LatLng(
          courier.currentLocation?.coordinates[1] ?? 0,
          courier.currentLocation?.coordinates[0] ?? 0);
      _setupMap(delivery, courier, courierLocation);
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

  void _listenToCourierLocationChanges() {
    _socketService.emit("joinDeliveryRoom", {"deliveryId": widget.deliveryId});

    _socketService.on("locationChanged", (data) {
      if (data['latitude'] != null && data['longitude'] != null) {
        setState(() {
          _addMarker('currentLocation',
              LatLng(data['latitude'], data['longitude']), vehicleIcon);
        });
      }
    });
  }

  void _setupMap(DeliveryModel delivery, UserModel courier,
      LatLng currentLocationLatLng) async {
    final originLatLng =
        LatLng(delivery.origin.coordinates[1], delivery.origin.coordinates[0]);
    final destinationLatLng = LatLng(delivery.destination.coordinates[1],
        delivery.destination.coordinates[0]);

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

  void _addMarker(String id, LatLng latLng, BitmapDescriptor? icon) {
    _markers.removeWhere((marker) => marker.markerId == MarkerId(id));

    _markers.add(Marker(
        markerId: MarkerId(id),
        position: latLng,
        icon: icon ?? BitmapDescriptor.defaultMarker));
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
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  myLocationEnabled: true,
                  initialCameraPosition: _initialCameraPosition!,
                  markers: _markers,
                  onMapCreated: (controller) =>
                      _googleMapController = controller,
                ),
                DeliveryDetailsCard(
                  origin: _delivery?.origin,
                  destination: _delivery?.destination,
                  name: _courier?.name ?? '',
                  phone: _courier?.phone ?? '',
                  price: _delivery?.price ?? 0,
                )
              ],
            ),
    );
  }
}
