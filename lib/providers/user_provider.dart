import 'package:be_fast/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../api/users.dart';
import '../shared/utils/user_session.dart';

class UserProvider extends ChangeNotifier {
  String _id = '';
  String _phone = '';
  String _name = '';
  String _vehicle = '';
  String _role = '';
  bool _isDisabled = false;
  int _credits = 0;

  String get id => _id;
  String get phone => _phone;
  String get name => _name;
  String get vehicle => _vehicle;
  String get role => _role;
  bool get isDisabled => _isDisabled;
  int get credits => _credits;

  UserProvider() {
    _initUser();
  }

  Future _initUser() async {
    String? userId = await UserSession.getUserId();
    UserModel user = await UsersAPI.getUser(userId: userId);
    initUserValues(user);
    FlutterNativeSplash.remove();
  }

  initUserValues(UserModel user) {
    _id = user.id;
    _phone = user.phone;
    _name = user.name;
    _vehicle = user.vehicle;
    _role = user.role;
    _isDisabled = user.isDisabled;
    _credits = user.credits;
    notifyListeners();
  }

  void updateUserName(String name) {
    _name = name;
    notifyListeners();
  }

  void updateUserVehicle(String vehicle) {
    _vehicle = vehicle;
    notifyListeners();
  }
}
