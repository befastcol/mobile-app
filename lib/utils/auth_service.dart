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
          debugPrint("sendOtp $error");
        },
        codeSent: (verificationId, forceResendingToken) async {
          verifyId = verificationId;
          forceResendingToken = forceResendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) async {},
      );
    } catch (e) {
      debugPrint("sendOtp $e");
      throw Exception(e);
    }
  }

  static Future<bool> loginWithOtp({required String otp}) async {
    final credential =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      return userCredential.user != null;
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
          debugPrint("resendOtp $error");
        },
        codeSent: (verificationId, resendingToken) async {
          verifyId = verificationId;
          forceResendingToken = resendingToken;
        },
        codeAutoRetrievalTimeout: (verificationId) async {},
      );
    } catch (e) {
      debugPrint("resendOtp $e");
      throw Exception(e);
    }
  }
}
