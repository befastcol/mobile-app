import 'package:be_fast/api/users.dart';
import 'package:be_fast/providers/user.dart';
import 'package:be_fast/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Vehicle extends StatefulWidget {
  final String vehicle, id;
  const Vehicle({super.key, required this.vehicle, required this.id});

  @override
  State<Vehicle> createState() => _VehicleState();
}

class _VehicleState extends State<Vehicle> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _selectedVehicle;
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.vehicle;
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Center(
              child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image(
                      image: _selectedVehicle == "motorcycle"
                          ? const AssetImage('assets/images/login.png')
                          : const AssetImage('assets/images/car_image.png'),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Vehículo",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Escoge con qué trabajarás hoy',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: RadioListTile<String>(
                      title: const Text('Moto'),
                      value: 'motorcycle',
                      groupValue: _selectedVehicle,
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicle = value!;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: RadioListTile<String>(
                      title: const Text('Carro'),
                      value: 'car',
                      groupValue: _selectedVehicle,
                      onChanged: (value) {
                        setState(() {
                          _selectedVehicle = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                UserProvider provider =
                                    context.read<UserProvider>();
                                _saveUserVehicle(provider);
                              }
                            },
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
      ),
    );
  }

  void _saveUserVehicle(UserProvider provider) async {
    setState(() => _isLoading = true);
    try {
      await UsersAPI.updateUserVehicle(
          userId: widget.id, vehicle: _selectedVehicle);
      provider.updateUserVehicle(_selectedVehicle);
      if (mounted) {
        showSnackBar(context, "Vehículo guardado correctamente");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
