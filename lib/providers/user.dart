import 'package:be_fast/api/users.dart';
import 'package:flutter/material.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/user_session.dart';

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel(id: '', name: '', phone: '', role: '');
  UserModel get user => _user;

  Future initializeUser() async {
    try {
      String? userId = await UserSession.getUserId();
      _user = await UsersAPI().getUserById(userId: userId);
      notifyListeners();
    } catch (e) {
      debugPrint("initializeUser: $e");
    }
  }

  void updateUserName(String newName) {
    _user = UserModel(
        id: _user.id, name: newName, phone: _user.phone, role: _user.role);
    notifyListeners();
  }
}
