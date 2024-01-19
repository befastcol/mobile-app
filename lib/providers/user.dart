import 'package:be_fast/api/constants.dart';
import 'package:be_fast/api/models/user.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
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
  }

  void updateUserName(String newName) {
    if (state != null) {
      state = state!.copyWith(name: newName);
    }
  }
}
