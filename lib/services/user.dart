import 'dart:convert';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/services/url.dart' as url;
import 'package:http/http.dart' as http;
import 'package:postman/models/response_data_list.dart';

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
          return ResponseDataMap(status: false, message: message.trim());
        }
      } else {
        return ResponseDataMap(
          status: false,
          message:
              "Gagal menambah user dengan kode error ${register.statusCode}",
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

  // Di dalam class UserService

  // Ambil data barang/pesanan (sesuaikan endpoint dengan backend Anda)
  Future<ResponseDataList> getBarangUser() async {
    var uri = Uri.parse("${url.BaseUrl}/user/getbarang");
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      return ResponseDataList(
        success: false,
        message: 'Anda belum login / token invalid',
        data: [],
      );
    }
    Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};
    var response = await http.get(uri, headers: headers);

    print('=== GET BARANG RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data["status"] == true) {
        List barang = data["data"] is List ? data["data"] : [];

        print('Total barang: ${barang.length}');
        if (barang.isNotEmpty) {
          print('First item keys: ${barang[0].keys}');
          print('First item: ${barang[0]}');
        }
        print('==========================');

        return ResponseDataList(
          success: true,
          message: 'Sukses memuat data',
          data: barang,
        );
      } else {
        return ResponseDataList(
          success: false,
          message: data["message"] ?? 'Gagal memuat data',
          data: [],
        );
      }
    } else {
      return ResponseDataList(
        success: false,
        message: "Gagal memuat data dengan kode error ${response.statusCode}",
        data: [],
      );
    }
  }

  // Update status pesanan
  Future<ResponseDataMap> updateStatusPesanan(int id, String newStatus) async {
    var uri = Uri.parse(
      "${url.BaseUrl}/user/updateStatus",
    ); // sesuaikan endpoint
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      return ResponseDataMap(status: false, message: "Token invalid");
    }
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      "Content-Type": "application/json",
    };
    var response = await http.post(
      uri,
      headers: headers,
      body: json.encode({"id": id, "status": newStatus}),
    );

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      if (body["status"] == true) {
        return ResponseDataMap(
          status: true,
          message: body["message"] ?? "Berhasil update status",
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: body["message"] ?? "Gagal update status",
        );
      }
    } else {
      return ResponseDataMap(
        status: false,
        message: "Server error ${response.statusCode}",
      );
    }
  }

  // Hapus pesanan
  Future<ResponseDataMap> deletePesanan(int id) async {
    var uri = Uri.parse(
      "${url.BaseUrl}/user/deletePesanan/$id",
    ); // sesuaikan endpoint
    var user = await UserLogin().getUserLogin();
    if (user.status == false) {
      return ResponseDataMap(status: false, message: "Token invalid");
    }
    Map<String, String> headers = {"Authorization": 'Bearer ${user.token}'};
    var response = await http.delete(uri, headers: headers);

    if (response.statusCode == 200) {
      var body = json.decode(response.body);
      if (body["status"] == true) {
        return ResponseDataMap(status: true, message: "Berhasil hapus pesanan");
      } else {
        return ResponseDataMap(
          status: false,
          message: body["message"] ?? "Gagal hapus pesanan",
        );
      }
    } else {
      return ResponseDataMap(
        status: false,
        message: "Gagal hapus, kode error ${response.statusCode}",
      );
    }
  }
}
