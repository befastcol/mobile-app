import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:be_fast/providers/map.dart';
import 'package:be_fast/utils/debounce.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  final String originTitle, destinationTitle;
  final bool isSelectingOrigin;

  const LocationSelectionScreen(
      {super.key,
      required this.originTitle,
      required this.destinationTitle,
      required this.isSelectingOrigin});

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<dynamic> _originAutocompleteResults = [];
  List<dynamic> _destinationAutocompleteResults = [];

  final Debounce _debounce = Debounce(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _originController.text = widget.originTitle;
    _destinationController.text = widget.destinationTitle;
  }

  void onOriginChanged(String value) {
    setState(() => _destinationAutocompleteResults = []);
    _debounce.run(() async {
      Position position = await LocationHelper.determinePosition();
      List<dynamic> results =
          await GoogleMapsAPI().getAutocompleteResults(value, position);

      setState(() => _originAutocompleteResults = results.take(4).toList());
    });
  }

  void onDestinationChanged(String value) {
    setState(() => _originAutocompleteResults = []);
    _debounce.run(() async {
      Position position = await LocationHelper.determinePosition();
      List<dynamic> results =
          await GoogleMapsAPI().getAutocompleteResults(value, position);

      setState(
          () => _destinationAutocompleteResults = results.take(4).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, mapProvider, child) => Scaffold(
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
                        autofocus: widget.isSelectingOrigin,
                        controller: _originController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.location_on, color: Colors.blue),
                          hintText: '¿De dónde salimos?',
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 16, 12, 16),
                        ),
                        onChanged: onOriginChanged,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        autofocus: !widget.isSelectingOrigin,
                        controller: _destinationController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.location_on, color: Colors.red),
                          hintText: '¿A dónde vamos?',
                          fillColor: Colors.grey[100],
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 16, 12, 16),
                        ),
                        onChanged: onDestinationChanged,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _originAutocompleteResults.isNotEmpty,
                      child: Expanded(
                        child: ListView.builder(
                          itemCount: _originAutocompleteResults.length,
                          itemBuilder: (context, index) {
                            var result = _originAutocompleteResults[index];
                            String title =
                                result['structured_formatting']['main_text'];
                            String subtitle = result['structured_formatting']
                                ['secondary_text'];
                            String placeId = result['place_id'];

                            return ListTile(
                              onTap: () async {
                                Navigator.pop(context);
                                mapProvider.setIsUpdatingLocation(true);
                                LatLng latLng = await GoogleMapsAPI()
                                    .getPlaceLatLng(placeId);
                                mapProvider.updateOrigin(
                                    latLng, title, subtitle);
                              },
                              leading: const Icon(Icons.location_on,
                                  color: Colors.blue),
                              title: Text(title),
                              subtitle: Text(subtitle,
                                  style: const TextStyle(color: Colors.grey)),
                            );
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _destinationAutocompleteResults.isNotEmpty,
                      child: Expanded(
                        child: ListView.builder(
                          itemCount: _destinationAutocompleteResults.length,
                          itemBuilder: (context, index) {
                            var result = _destinationAutocompleteResults[index];
                            String title =
                                result['structured_formatting']['main_text'];
                            String subtitle = result['structured_formatting']
                                ['secondary_text'];
                            String placeId = result['place_id'];

                            return ListTile(
                              onTap: () async {
                                try {
                                  Navigator.pop(context);
                                  mapProvider.setIsUpdatingLocation(true);
                                  LatLng latLng = await GoogleMapsAPI()
                                      .getPlaceLatLng(placeId);
                                  mapProvider.updateDestination(
                                      latLng, title, subtitle);
                                } catch (e) {
                                  debugPrint("$e");
                                }
                              },
                              leading: const Icon(Icons.location_on,
                                  color: Colors.red),
                              title: Text(title),
                              subtitle: Text(subtitle,
                                  style: const TextStyle(color: Colors.grey)),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
