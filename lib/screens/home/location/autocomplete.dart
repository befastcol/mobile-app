import 'package:be_fast/api/google_maps.dart';
import 'package:be_fast/providers/user.dart';
import 'package:be_fast/utils/location_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'package:be_fast/utils/debounce.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AutocompleteScreen extends StatefulWidget {
  final Function setIsLoadingLocation;
  final String originTitle;
  const AutocompleteScreen(
      {super.key,
      required this.originTitle,
      required this.setIsLoadingLocation});

  @override
  State<AutocompleteScreen> createState() => _AutocompleteScreenState();
}

class _AutocompleteScreenState extends State<AutocompleteScreen> {
  TextEditingController _locationController = TextEditingController();
  List<dynamic> _autocompleteResults = [];
  final Debounce _debounce = Debounce(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.originTitle);
  }

  @override
  void dispose() {
    super.dispose();
    _locationController.dispose();
  }

  void _onLocationChanged(String value) {
    _debounce.run(() async {
      Position position = await LocationHelper.determinePosition();
      List<dynamic> results =
          await GoogleMapsAPI().getAutocompleteResults(value, position);

      setState(() => _autocompleteResults = results.take(4).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
        builder: (context, provider, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: const Text('Ubicación'),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Hero(
                      tag: 'location',
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          autofocus: true,
                          controller: _locationController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.location_on,
                                color: Colors.blue),
                            hintText: 'Ubicación',
                            fillColor: Colors.grey[100],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(12, 16, 12, 16),
                          ),
                          onChanged: _onLocationChanged,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _autocompleteResults.isNotEmpty,
                      child: Expanded(
                        child: ListView.builder(
                          itemCount: _autocompleteResults.length,
                          itemBuilder: (context, index) {
                            var result = _autocompleteResults[index];
                            String title =
                                result['structured_formatting']['main_text'];
                            String subtitle = result['structured_formatting']
                                ['secondary_text'];
                            String placeId = result['place_id'];

                            return ListTile(
                              onTap: () async {
                                try {
                                  widget.setIsLoadingLocation(true);
                                  Navigator.pop(context);
                                  final result = await GoogleMapsAPI()
                                      .getPlaceLatLng(placeId);
                                  final LatLng latLng = result['latLng'];
                                  final String city = result['city'];

                                  print(city);
                                  print(latLng);

                                  provider.updateOrigin(
                                      latLng, title, subtitle, city);
                                } finally {
                                  widget.setIsLoadingLocation(false);
                                }
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
                  ],
                ),
              ),
            ));
  }
}
