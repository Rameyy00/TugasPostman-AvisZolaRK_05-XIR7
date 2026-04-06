import 'dart:convert';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;
import 'package:http/http.dart' as http;

class UserService {
  Future registerUser(Map<String, dynamic> data) async {
    var uri = Uri.parse("${url.BaseUrl}/auth/register");

    try {
      var register = await http.post(
        uri,
        body: data, // For form data, consider adding headers if needed
      );

      if (register.statusCode == 200) {
        var responseBody = json.decode(register.body);

        if (responseBody["status"] == true) {
          return ResponseDataMap(
            status: true,
            message: "Sukses menambah user",
            data: responseBody,
          );
        } else {
          String message = '';
          // Handle both Map and String error messages
          if (responseBody["message"] is Map) {
            for (String key in responseBody["message"].keys) {
              message += '${responseBody["message"][key][0]}\n';
            }
          } else {
            message = responseBody["message"] ?? "Terjadi kesalahan";
          }
          return ResponseDataMap(
            status: false,
            message: message.trim(),
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: "Gagal menambah user dengan kode error ${register.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Gagal terhubung ke server: $e",
      );
    }
  }

  Future loginUser(Map<String, dynamic> data) async {
    var uri = Uri.parse("${url.BaseUrl}/auth/login");

    try {
      var login = await http.post(uri, body: data);

      if (login.statusCode == 200) {
        var responseBody = json.decode(login.body);

        if (responseBody["status"] == true) {
          UserLogin userLogin = UserLogin(
            status: responseBody["status"],
            token: responseBody["token"],
            massage: responseBody["message"],
            userId: responseBody["user"]["id"],
            nama_user: responseBody["user"]["nama_user"],
            email: responseBody["user"]["email"],
            role: responseBody["user"]["role"],
          );

          await userLogin.saveToPreferences();

          return ResponseDataMap(
            status: true,
            message: responseBody["message"],
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: responseBody["message"] ?? "Email atau Password salah",
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: "Server error ${login.statusCode}",
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Gagal terhubung ke server: $e",
      );
    }
  }
}