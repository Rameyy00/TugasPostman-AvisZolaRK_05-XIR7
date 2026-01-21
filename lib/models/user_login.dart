// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status = false;
  String? token;
  String? massage;
  int? userId;
  String? nama_user;
  String? email;
  String? role;
  UserLogin({
    this.status,
    this.token,
    this.massage,
    this.userId,
    this.nama_user,
    this.email,
    this.role,
  });

  Future<void> saveToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('status', status!);
    prefs.setString('token', token!);
    prefs.setString('massage', massage!);
    prefs.setInt('userId', userId!);
    prefs.setString('nama_user', nama_user!);
    prefs.setString('email', email!);
    prefs.setString('role', role!);
  }

  Future getUserLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    UserLogin userLogin = UserLogin(
      status: prefs.getBool('status')!,
      token: prefs.getString('token')!,
      massage: prefs.getString('massage')!,
      userId: prefs.getInt('userId')!,
      nama_user: prefs.getString('nama_user')!,
      email: prefs.getString('email')!,
      role: prefs.getString('role')!,
    );
    return userLogin;
  }

  static Future logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }
}
