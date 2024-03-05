import 'dart:async';
import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/show_snack_bar.dart';
import 'package:be_fast/utils/socket_service.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:be_fast/utils/bytes_from_asset.dart';
import 'package:audioplayers/audioplayers.dart';

class CourierMap extends StatefulWidget {
  const CourierMap({super.key});

  @override
  State<CourierMap> createState() => _CourierMapState();
}

class _CourierMapState extends State<CourierMap> {
  GoogleMapController? _googleMapController;
  CameraPosition? _initialCameraPosition;
  Set<Marker> _markers = {};
  final SocketService _socketService = SocketService();

  UserModel? _courier;
  bool _isServiceAvailable = false;
  Timer? _locationTimer;
  Position? _lastPosition;
  String? _currentVehicle = 'motorcycle';

  @override
  void initState() {
    super.initState();
    _socketService.initSocket();
    _initCourier();
    _listenToDeliveryUpdates();
    _startLocationTimer();
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    _socketService.dispose();
    _locationTimer?.cancel();

    super.dispose();
  }

  Future _initCourier() async {
    _initCurrentLocation();
    _setupMap();

    setIcon(_courier?.vehicle);
  }

  Future _initCurrentLocation() async {
    try {
      String? courierId = await UserSession.getUserId();
      _courier = await UsersAPI().getUser(userId: courierId);

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _socketService.emit('updateLocation', {
        'courierId': courierId,
        'latitude': position.latitude,
        'longitude': position.longitude,
      });
    } catch (e) {
      debugPrint('Error sending location update: $e');
    }
  }

  Future<void> setIcon(String? vehicle) async {
    String iconPath = vehicle == 'motorcycle'
        ? 'assets/images/moto_icon.png'
        : 'assets/images/car_icon.png';
    BitmapDescriptor icon = await getBytesFromAsset(iconPath, 100);

    setState(() {
      _currentVehicle = vehicle;
    });

    Position? currentPosition = await Geolocator.getLastKnownPosition();
    if (currentPosition != null) {
      updateMarker(currentPosition, icon);
    }

    try {
      await UsersAPI()
          .updateUserVehicle(userId: _courier?.id, vehicle: vehicle!);
    } catch (e) {
      if (mounted) {
        showSnackBar(context, "Error al actualizar el vehiculo.");
      }
    }
  }

  void _setupMap() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 19,
        tilt: 60);
    updateMarker(position);
  }

  void _startLocationTimer() {
    const duration = Duration(seconds: 1);
    _locationTimer = Timer.periodic(duration, (Timer t) async {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition?.latitude ?? 0,
        _lastPosition?.longitude ?? 0,
        currentPosition.latitude,
        currentPosition.longitude,
      );
      print(distanceInMeters);

      if (_lastPosition == null || distanceInMeters > 50) {
        _lastPosition = currentPosition;
        updateMarker(currentPosition);

        try {
          _socketService.emit('updateLocation', {
            'courierId': _courier?.id,
            'latitude': currentPosition.latitude,
            'longitude': currentPosition.longitude,
          });
        } catch (e) {
          debugPrint('Error sending location update: $e');
        }
      }
    });
  }

  Future _listenToDeliveryUpdates() async {
    String? courierId = await UserSession.getUserId();
    final player = AudioPlayer();

    _socketService.on("$courierId", (data) async {
      if (mounted) {
        setState(() => _isServiceAvailable = true);
        await player.play(AssetSource('sounds/notification_sound.wav'));
      }
    });
  }

  void updateMarker(Position position, icon) {
    if (mounted) {
      setState(() {
        _markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
            icon: icon,
          ),
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
          actions: <Widget>[
            IconButton(
              icon: Icon(_currentVehicle == 'motorcycle'
                  ? Icons.motorcycle
                  : Icons.directions_car),
              onPressed: () {
                String newVehicle =
                    _currentVehicle == 'motorcycle' ? 'car' : 'motorcycle';
                setIcon(newVehicle);
              },
            ),
          ],
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
