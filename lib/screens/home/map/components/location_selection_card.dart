import 'package:flutter/material.dart';
import 'package:be_fast/screens/home/map/components/location_selection_screen.dart';
import 'package:be_fast/utils/location_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../models/location.dart';

class LocationSelectionCard extends StatefulWidget {
  const LocationSelectionCard({
    Key? key,
  }) : super(key: key);

  @override
  State<LocationSelectionCard> createState() => _LocationSelectionCardState();
}

class _LocationSelectionCardState extends State<LocationSelectionCard> {
  Location origin = Location(coordinates: [], title: '', subtitle: '');
  Location destination = Location(coordinates: [], title: '', subtitle: '');

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await LocationHelper.determinePosition();
    String place = await LocationHelper.getAddressFromLatLng(
        position.latitude, position.longitude);
    String longPlace = await LocationHelper.getLongPlace(position);
    updateOrigin(
        LatLng(position.latitude, position.longitude), place, longPlace);
  }

  void updateOrigin(LatLng latlng, String title, String subtitle) {
    if (mounted) {
      setState(() {
        origin = Location(
            coordinates: [latlng.latitude, latlng.longitude],
            title: title,
            subtitle: subtitle);
      });
    }
  }

  void updateDestination(LatLng latlng, String title, String subtitle) {
    if (mounted) {
      setState(() {
        destination = Location(
            coordinates: [latlng.latitude, latlng.longitude],
            title: title,
            subtitle: subtitle);
      });
    }
  }

  void onFindCouriersPressed() {}

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (destination.coordinates.isNotEmpty)
              Column(
                children: [
                  _buildInkWellItem(
                    context: context,
                    iconData: Icons.location_on,
                    iconColor: Colors.blue,
                    text: origin.title,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            _buildInkWellItem(
              context: context,
              iconData: Icons.location_on,
              iconColor: Colors.red,
              text: destination.title.isEmpty
                  ? '¿A dónde vamos?'
                  : destination.title,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFindCouriersPressed,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Buscar repartidores',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInkWellItem({
    required BuildContext context,
    required IconData iconData,
    required Color iconColor,
    required String text,
  }) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LocationSelectionScreen(
                        originTitle: origin.title,
                        destinationTitle: destination.title,
                        updateOrigin: updateOrigin,
                        updateDestination: updateDestination,
                      )));
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
          child: Row(
            children: [
              Icon(iconData, color: iconColor),
              const SizedBox(width: 10),
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
