import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:be_fast/constants/api.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/user_session.dart';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      String? userId = await UserSession.getUserId();
      if (userId == null) {
        state = null;
        return;
      }

      final url = Uri.parse('$baseUrl/user/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        state = UserModel.fromJson(user);
      } else {
        state = null;
      }
    } catch (e) {
      state = null;
    }
  }

  void updateUserName(String newName) {
    if (state != null) {
      state = state!.copyWith(name: newName);
    }
  }
}
