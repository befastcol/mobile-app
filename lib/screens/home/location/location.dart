import 'package:be_fast/api/users.dart';
import 'package:be_fast/providers/delivery_provider.dart';
import 'package:be_fast/screens/home/location/autocomplete.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool _isSaving = false;
  bool _isLoadingLocation = false;

  setIsLoadingLocation(bool isLoading) {
    setState(() => _isLoadingLocation = isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(builder: (context, deliveryState, child) {
      Future saveUserLocation() async {
        try {
          setState(() => _isSaving = true);
          String? userId = await UserSession.getUserId();

          await UsersAPI.saveUserLocation(
              userId: userId, originLocation: deliveryState.origin);
          if (mounted) {
            showSnackBar(context, "Ubicación guardada correctamente");
          }
        } finally {
          if (mounted) {
            setState(() => _isSaving = false);
          }
        }
      }

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Image(
                    image: AssetImage('assets/images/location.png'),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Ubicación",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '¿Dónde podemos encontrarte?',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'location',
                    child: Material(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                      child: _isLoadingLocation
                          ? Container(height: 56)
                          : InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AutocompleteScreen(
                                      originTitle: deliveryState.origin.title,
                                      setIsLoadingLocation:
                                          setIsLoadingLocation),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 16, 12, 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.blue),
                                    const SizedBox(width: 10),
                                    Text(deliveryState.origin.title.isEmpty
                                        ? 'Ubicación'
                                        : deliveryState.origin.title),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _isSaving
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                deliveryState.origin.coordinates.isNotEmpty &&
                                        !_isLoadingLocation
                                    ? saveUserLocation
                                    : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              'Guardar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          )),
        ),
      );
    });
  }
}
