import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesData {

  Future<void> setUserName(String username) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('username', username);
  }

  Future<String> getUserName(String usernameKey) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String username;
    username = pref.getString(usernameKey) ?? '';
    return username;
  }

  Future<void> removeUserName(String usernameKey) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(usernameKey);
    print("====remove pref UserName=====");
  }

  Future<void> setUserId(String userId) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('userid', userId);
  }

  Future<String> getUserId(String useridKey) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String userid;
    userid = pref.getString(useridKey) ?? '';
    return userid;
  }

  Future<void> removeUserId(String useridKey) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(useridKey);
    print("====remove pref UserID=====");
  }


}
