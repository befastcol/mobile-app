import 'package:be_fast/api/user.dart';
import 'package:be_fast/models/user.dart';
import 'package:be_fast/utils/user_session.dart';

Future<UserModel> getUserData() async {
  try {
    String? userId = await UserSession.getUserId();
    return await getUserById(userId);
  } catch (e) {
    return UserModel(id: '', name: '', phone: '', role: '');
  }
}
