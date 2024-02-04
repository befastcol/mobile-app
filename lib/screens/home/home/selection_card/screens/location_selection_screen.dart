import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:be_fast/providers/map_provider.dart';
import 'package:be_fast/utils/debounce.dart';
import 'package:be_fast/screens/home/home/helpers/location_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSelectionScreen extends StatefulWidget {
  final String originTitle, destinationTitle;

  const LocationSelectionScreen(
      {Key? key, required this.originTitle, required this.destinationTitle})
      : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<dynamic> _originAutocompleteResults = [];
  List<dynamic> _destinationAutocompleteResults = [];
  final Debounce _debounce = Debounce(milliseconds: 200);
  bool _isSelectingOrigin = false;

  @override
  void initState() {
    super.initState();
    _originController.text = widget.originTitle;
    _destinationController.text = widget.destinationTitle;
  }

  void _getAutocompleteResults(String value, bool isOrigin) async {
    List<dynamic> results = await LocationHelper.getAutocompleteResults(value);

    setState(() {
      if (isOrigin) {
        _originAutocompleteResults = results.take(4).toList();
      } else {
        _destinationAutocompleteResults = results.take(4).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
        builder: (context, value, child) => Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: const Text('Ubicación'),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _originController,
                      hintText: '¿De dónde sale?',
                      iconColor: Colors.blue,
                      onChanged: (text) {
                        _isSelectingOrigin = true;
                        _debounce
                            .run(() => _getAutocompleteResults(text, true));
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _destinationController,
                      hintText: '¿A dónde vamos?',
                      iconColor: Colors.red,
                      onChanged: (text) {
                        _isSelectingOrigin = false;
                        _debounce
                            .run(() => _getAutocompleteResults(text, false));
                      },
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _isSelectingOrigin
                            ? _originAutocompleteResults.length
                            : _destinationAutocompleteResults.length,
                        itemBuilder: (context, index) {
                          var result = _isSelectingOrigin
                              ? _originAutocompleteResults[index]
                              : _destinationAutocompleteResults[index];
                          String title =
                              result['structured_formatting']['main_text'];
                          String subtitle =
                              result['structured_formatting']['secondary_text'];
                          String placeId = result['place_id'];

                          return ListTile(
                            onTap: () async {
                              Navigator.pop(context);
                              LatLng latLng =
                                  await LocationHelper.getPlaceLatLng(placeId);
                              if (_isSelectingOrigin) {
                                value.updateOrigin(latLng, title, subtitle);
                              } else {
                                value.updateDestination(
                                    latLng, title, subtitle);
                              }
                            },
                            leading: const Icon(Icons.location_on,
                                color: Colors.grey),
                            title: Text(title),
                            subtitle: Text(subtitle,
                                style: const TextStyle(color: Colors.grey)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required Color iconColor,
    required Function(String) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.location_on, color: iconColor),
          hintText: hintText,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
