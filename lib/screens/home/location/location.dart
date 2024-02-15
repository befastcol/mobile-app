// import 'package:be_fast/api/users.dart';
import 'package:be_fast/providers/user.dart';
// import 'package:be_fast/utils/debounce.dart';
import 'package:be_fast/utils/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Location extends StatefulWidget {
  final String id;
  const Location({super.key, required this.id});

  @override
  State<Location> createState() => _LocationState();
}

class _LocationState extends State<Location> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _originController = TextEditingController();
  // final Debounce _debounce = Debounce(milliseconds: 500);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _originController.dispose();
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
                    '¿Dónde podemos ubicarte?',
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _originController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Ubicación',
                        hintText: 'Ubicación'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduce tu ubicación por favor';
                      }
                      return null;
                    },
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
                                final userProvider =
                                    context.read<UserProvider>();
                                _saveUser(userProvider);
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

  void _saveUser(UserProvider userProvider) async {
    setState(() => _isLoading = true);
    try {
      // await UsersAPI().updateUserLocation(
      //     userId: widget.id, originLocation: _originController.text);
      if (mounted) {
        showSnackBar(context, "Ubicación guardada correctamente");
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
