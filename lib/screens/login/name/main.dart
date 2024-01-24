import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/material.dart';

import '../../../api/user.dart';
import 'package:be_fast/screens/home/map/main.dart';

class Name extends StatefulWidget {
  final String phoneNumber;

  const Name({super.key, required this.phoneNumber});

  @override
  State<Name> createState() => _NameState();
}

class _NameState extends State<Name> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _nameController;
  late bool _isLoading;

  void _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String userId =
          await createUser(_nameController.text, widget.phoneNumber);
      debugPrint(userId);
      await UserSession.storeUserId(userId);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController();
    _isLoading = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Image(
                      image: AssetImage('assets/name.png'),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      '¡Hola!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Nos gustaría saber cómo te llamas',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nombre',
                          hintText: 'Nombre Apellido'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Introduce tu nombre por favor';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    if (!_isLoading)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
