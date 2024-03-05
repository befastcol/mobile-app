import 'package:be_fast/api/users.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/foundation.dart';

class CourierStateProvider with ChangeNotifier {
  UserModel? _courier;
  bool _isToggled = false;

  UserModel? get courier => _courier;
  bool get isToggled => _isToggled;

  Future initCourier() async {
    try {
      String? courierId = await UserSession.getUserId();
      _courier = await UsersAPI.getUser(userId: courierId);

      checkIfIsAvailable();
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future _updateCourierStatus(String status) async {
    try {
      String? courierId = await UserSession.getUserId();
      _courier =
          await UsersAPI.updateCourierStatus(userId: courierId, status: status);
      notifyListeners();
    } catch (e) {
      debugPrint("$e");
    }
  }

  void setToggled() {
    _isToggled = !_isToggled;
    _updateCourierStatus(_isToggled ? 'available' : 'inactive');
    notifyListeners();
  }

  void checkIfIsAvailable() {
    if (_courier?.status == 'available' || _courier?.status == 'busy') {
      _isToggled = true;
    }
  }
}
