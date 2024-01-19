import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static String verifyId = "";
  static int? forceResendingToken;

  static Future<void> sendOtp({
    required String phone,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        timeout: const Duration(seconds: 30),
        phoneNumber: "+52$phone",
        verificationCompleted: (phoneAuthCredential) async {},
        verificationFailed: (error) async {
          debugPrint("Falló $error");
        },
        codeSent: (verificationId, forceResendingToken) async {
          verifyId = verificationId;
          forceResendingToken = forceResendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) async {},
      );
    } catch (e) {
      debugPrint("Error $e");
      throw Exception(e);
    }
  }

  static Future<bool> loginWithOtp({required String otp}) async {
    final cred =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(cred);

      if (userCredential.user != null) {
        return true;
      } else {
        return false;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Error de Firebase: ${e.message}');
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  static Future<bool> isLoggedIn() async {
    var user = _firebaseAuth.currentUser;
    return user != null;
  }

  static Future<void> resendOtp({
    required String phone,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        timeout: const Duration(seconds: 29),
        phoneNumber: "+52$phone",
        forceResendingToken: forceResendingToken,
        verificationCompleted: (phoneAuthCredential) async {},
        verificationFailed: (error) async {
          debugPrint("Falló $error");
        },
        codeSent: (verificationId, resendingToken) async {
          verifyId = verificationId;
          forceResendingToken = resendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) async {},
      );
    } catch (e) {
      debugPrint("Error $e");
      throw Exception(e);
    }
  }
}
