import 'dart:async';

import 'package:be_fast/utils/auth_service.dart';
import 'package:be_fast/screens/login/name/main.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PhoneVerification extends StatefulWidget {
  final String phoneNumber;

  const PhoneVerification({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final TextEditingController _codeController = TextEditingController();

  StreamController<ErrorAnimationType>? _errorController;
  Timer? _timer;
  int _start = 30;
  bool _isResendButtonEnabled = true;
  bool _isLoading = false;

  bool hasError = false;
  final _formKey = GlobalKey<FormState>();

  void startTimer() {
    setState(() {
      _isResendButtonEnabled = false;
      _start = 30;
    });
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 1) {
          setState(() {
            _isResendButtonEnabled = true;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _onLoginPressed() {
    if (!_formKey.currentState!.validate()) {
      _errorController?.add(ErrorAnimationType.shake);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    AuthService.loginWithOtp(otp: _codeController.text).then((isValid) {
      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        _navigateToNextScreen();
      } else {
        _errorController?.add(ErrorAnimationType.shake);
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _navigateToNextScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
          builder: (context) => Name(phoneNumber: widget.phoneNumber)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    _errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    _errorController!.close();
    _timer?.cancel();
    super.dispose();
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {},
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: const Image(
                    image: AssetImage('assets/pin.png'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Verifica tu teléfono',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                    text: "Escribe el código enviado a ",
                    children: [
                      TextSpan(
                        text: widget.phoneNumber,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 30,
                  ),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    obscureText: true,
                    obscuringCharacter: '*',
                    blinkWhenObscuring: true,
                    errorAnimationDuration: 500,
                    animationType: AnimationType.fade,
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                        selectedColor: Colors.blueGrey,
                        selectedFillColor: Colors.white,
                        inactiveColor: Colors.blueGrey,
                        inactiveFillColor: Colors.white),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: _errorController,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length != 6) {
                        return '';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              if (!_isLoading)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Verificar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 10),
              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "¿No recibiste el código?",
                      style: TextStyle(color: Colors.black54, fontSize: 15),
                    ),
                    TextButton(
                      onPressed: _isResendButtonEnabled
                          ? () {
                              startTimer();
                              snackBar("Código reenviado.");
                              AuthService.resendOtp(phone: widget.phoneNumber);
                            }
                          : null,
                      child: Text(
                        _isResendButtonEnabled
                            ? "Reenviar"
                            : "Reenviar $_start",
                        style: TextStyle(
                          color: _isResendButtonEnabled
                              ? Colors.blueGrey
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
