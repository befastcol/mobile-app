import 'dart:async';

import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:be_fast/utils/bytes_from_asset.dart';
import 'package:socket_io_client/socket_io_client.dart';

class CourierMap extends StatefulWidget {
  const CourierMap({super.key});

  @override
  State<CourierMap> createState() => _CourierMapState();
}

class _CourierMapState extends State<CourierMap> {
  GoogleMapController? _googleMapController;
  CameraPosition? _initialCameraPosition;
  Set<Marker> _markers = {};
  bool _isServiceAvailable = false;
  StreamSubscription<Position>? _positionStreamSubscription;
  late Socket socket;
  late String? courierId;

  @override
  void initState() {
    super.initState();
    _initCourierId();
    _initSocket();
    _setupMap();
    _listenToLocationChanges();
    _listenToDeliveryUpdates();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _positionStreamSubscription?.cancel();
    socket.disconnect();
    super.dispose();
  }

  Future _initCourierId() async {
    courierId = await UserSession.getUserId();
  }

  Future _initSocket() async {
    try {
      socket = io('http://192.168.1.71:3000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      socket.connect();
    } catch (e) {
      debugPrint("_initSocket $e");
    }
  }

  void _setupMap() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 19);
    _updateMarker(position);
  }

  void _listenToLocationChanges() {
    const locationOptions =
        LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 20);

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationOptions)
            .listen((Position position) {
      _updateMarker(position);
      try {
        socket.emit('updateLocation', {
          'courierId': courierId,
          'latitude': position.latitude,
          'longitude': position.longitude
        });
      } catch (e) {
        debugPrint('Error sending location update: $e');
      }
    });
  }

  void _listenToDeliveryUpdates() {
    socket.on('newDelivery', (data) {
      if (data['courier'] == courierId) {
        if (mounted) {
          setState(() => _isServiceAvailable = true);
        }
      } else {
        if (mounted) {
          setState(() => _isServiceAvailable = false);
        }
      }
    });
  }

  void _updateMarker(Position position) async {
    final BitmapDescriptor motoIcon =
        await getBytesFromAsset('assets/moto_icon.png', 100);

    if (mounted) {
      setState(() {
        _markers = {
          Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude),
              icon: motoIcon),
        };
        _googleMapController?.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(_isServiceAvailable
              ? 'Servicio encontrado'
              : 'Esperando servicios...')),
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: _initialCameraPosition!,
                  onMapCreated: (controller) =>
                      _googleMapController = controller,
                  markers: _markers,
                ),
                Visibility(
                  visible: _isServiceAvailable,
                  child: Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Card(
                      surfaceTintColor: Colors.white,
                      color: Colors.white,
                      margin: const EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const ListTile(
                              title: Text("Colina de Vinimal 54"),
                              subtitle:
                                  Text("Calle Atenas, Villa de Álvarez, 28978"),
                              leading: Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                            ),
                            const ListTile(
                              title: Text("Sendera"),
                              subtitle:
                                  Text("Calle Atenas, Villa de Álvarez, 28978"),
                              leading: Icon(
                                Icons.location_on,
                                color: Colors.red,
                              ),
                            ),
                            const ListTile(
                              title: Text("\$40 MXN"),
                              leading: Icon(
                                Icons.payments,
                                color: Colors.teal,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      backgroundColor: Colors.blue),
                                  child: const Text('Aceptar',
                                      style: TextStyle(color: Colors.white)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
