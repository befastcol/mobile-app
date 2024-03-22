import 'package:flutter/material.dart';

import 'package:be_fast/screens/login/terms_and_conditions.dart';
import 'package:be_fast/screens/login/phone_veritication.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  bool _isAgreedToTerms = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _navigateToTermsAndConditions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsScreen(),
      ),
    );
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
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Image(
                      image: AssetImage('assets/images/login.png'),
                    ),
                    const SizedBox(height: 50),
                    const Text(
                      'Bienvenido',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Ingresa tu número de teléfono para comenzar.',
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLength: 10,
                      controller: phoneController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Teléfono',
                        hintText: '3120000000',
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 10) {
                          return 'Número de teléfono inválido';
                        }
                        return null;
                      },
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isAgreedToTerms,
                          onChanged: (bool? value) {
                            setState(() {
                              _isAgreedToTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _navigateToTermsAndConditions(context);
                            },
                            child: const Text(
                              'Acepto los términos y condiciones',
                              style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAgreedToTerms
                            ? () {
                                if (formKey.currentState!.validate()) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PhoneVerification(
                                        phone: phoneController.text,
                                      ),
                                    ),
                                  );
                                }
                              }
                            : null, // Esta parte deshabilita el botón si _isAgreedToTerms es falso
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: _isAgreedToTerms
                              ? Colors.blue
                              : Colors
                                  .grey, // Cambia el color si no está de acuerdo
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
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
