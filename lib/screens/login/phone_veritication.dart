import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/custom/custom.dart';
import 'package:be_fast/shared/utils/show_snack_bar.dart';
import 'package:be_fast/shared/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:be_fast/shared/utils/auth_service.dart';

import 'package:be_fast/screens/home/home/home.dart';
import 'package:be_fast/screens/login/name.dart';

class PhoneVerification extends StatefulWidget {
  final String phone;

  const PhoneVerification({
    super.key,
    required this.phone,
  });

  @override
  State<PhoneVerification> createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  final TextEditingController _codeController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController =
      StreamController<ErrorAnimationType>();
  Timer? _timer;
  int _start = 30;
  bool _isResendButtonEnabled = true, _isLoading = false, hasError = false;

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

  void _onVerificationPressed() async {
    if (!_formKey.currentState!.validate()) {
      _errorController.add(ErrorAnimationType.shake);
      return;
    }

    try {
      setState(() => _isLoading = true);
      bool isValid = await AuthService.loginWithOtp(otp: _codeController.text);

      if (!isValid) {
        _errorController.add(ErrorAnimationType.shake);
        return;
      }

      CreateUserResponse user =
          await UsersAPI().createUser(phone: widget.phone);
      await UserSession.storeUserId(userId: user.userId);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  user.alreadyExists ? const Home() : const Name()),
          (Route<dynamic> route) => false,
        );
      }
    } finally {
      setState(() => _isLoading = true);
    }
  }

  @override
  void initState() {
    super.initState();
    AuthService.sendOtp(phone: widget.phone);
  }

  @override
  void dispose() {
    super.dispose();
    _errorController.close();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: Colors.white,
      body: SizedBox(
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
                  image: AssetImage('assets/images/pin.png'),
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
                      text: widget.phone,
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
                    onPressed: _onVerificationPressed,
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
                            showSnackBar(context, "Código reenviado.");
                            AuthService.resendOtp(phone: widget.phone);
                          }
                        : null,
                    child: Text(
                      _isResendButtonEnabled ? "Reenviar" : "Reenviar $_start",
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
    );
  }
}
