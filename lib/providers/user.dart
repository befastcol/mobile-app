import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:be_fast/constants/api.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/user_session.dart';

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

      final url = Uri.parse('$baseUrl/users/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final user = json.decode(response.body);
        state = UserModel.fromJson(user);
      } else {
        throw Exception();
      }
    } catch (e) {
      state = null;
      debugPrint("Error getting user: e");
    }
  }

  void updateUserName(String newName) {
    if (state != null) {
      state = state!.copyWith(name: newName);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
