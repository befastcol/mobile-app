import 'package:be_fast/api/users.dart';
import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/home/home.dart';
import 'package:be_fast/screens/login/autocomplete.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class Location extends StatefulWidget {
  const Location({super.key});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  bool _isSaving = false;
  bool _isLoadingLocation = false;

  setIsLoadingLocation(bool isLoading) {
    setState(() => _isLoadingLocation = isLoading);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, child) {
      Future saveUserLocation() async {
        try {
          setState(() => _isSaving = true);
          String? userId = await UserSession.getUserId();

          await UsersAPI().saveUserLocation(
              userId: userId, originLocation: provider.origin);
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
              (Route<dynamic> route) => false,
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isSaving = false);
          }
        }
      }

      return Scaffold(
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
                    image: AssetImage('assets/location.png'),
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
                  Material(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    child: _isLoadingLocation
                        ? Container(height: 56)
                        : InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AutocompleteScreen(
                                    originTitle: provider.origin.title,
                                    setIsLoadingLocation: setIsLoadingLocation),
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
                                  Text(provider.origin.title.isEmpty
                                      ? 'Ubicación'
                                      : provider.origin.title),
                                ],
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
                            onPressed: provider.origin.coordinates.isNotEmpty &&
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
