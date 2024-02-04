import 'package:be_fast/utils/debounce.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:be_fast/utils/location_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  final String originTitle;
  final String destinationTitle;
  final Function updateOrigin;
  final Function updateDestination;

  const LocationSelectionScreen(
      {Key? key,
      required this.originTitle,
      required this.destinationTitle,
      required this.updateOrigin,
      required this.updateDestination})
      : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<dynamic> _autocompleteResults = [];
  Position? currentPosition;
  bool _isSelectingOrigin = true;

  @override
  void initState() {
    super.initState();
    _originController.text = widget.originTitle;
    _destinationController.text = widget.destinationTitle;
    _determinePosition();
    _checkSelectedInput();
  }

  void _checkSelectedInput() {
    _originController.addListener(() {
      _isSelectingOrigin = true;
    });
    _destinationController.addListener(() {
      _isSelectingOrigin = false;
    });
  }

  Future<void> _determinePosition() async {
    currentPosition = await LocationHelper.determinePosition();
  }

  void _onChanged(String text) {
    debounce(callback: _getAutocompleteResults)(text);
  }

  void _getAutocompleteResults(String value) async {
    List<dynamic> results =
        await LocationHelper.getAutocompleteResults(value, currentPosition);

    setState(() {
      _autocompleteResults = results.take(4).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Ubicación'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                autofocus: false,
                controller: _originController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                  hintText: '¿De dónde sale?',
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                ),
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: TextFormField(
                autofocus: true,
                controller: _destinationController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                  hintText: '¿A dónde vamos?',
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                ),
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(height: 10),
            Container(color: Colors.grey[100], height: 10),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _autocompleteResults.length,
                itemBuilder: (context, index) {
                  var result = _autocompleteResults[index];
                  String title = result['structured_formatting']['main_text'];
                  String subtitle =
                      result['structured_formatting']['secondary_text'];
                  String placeId = result['place_id'];
                  return ListTile(
                    onTap: () async {
                      Navigator.pop(context);
                      LatLng latlng =
                          await LocationHelper.getPlaceLatLng(placeId);
                      if (_isSelectingOrigin) {
                        widget.updateOrigin(latlng, title, subtitle);
                      } else {
                        widget.updateDestination(latlng, title, subtitle);
                      }
                    },
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(title),
                    subtitle: Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
