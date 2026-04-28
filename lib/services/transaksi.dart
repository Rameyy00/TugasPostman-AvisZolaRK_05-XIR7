import 'dart:convert';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/models/transaction_model.dart';
import 'package:postman/services/DBHelper.dart';
import 'package:postman/services/url.dart' as url;
import 'package:http/http.dart' as http;

class Pesan {
  UserLogin userLogin = UserLogin();

  Future saveToDB(dataRequest) async {
    var uri = Uri.parse("${url.BaseUrl}/user/transaksi");
    var user = await userLogin.getUserLogin();

    if (user.status == false) {
      return ResponseDataMap(
        status: false,
        message: 'Anda belum login / token invalid',
      );
    }
    print(dataRequest);
    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      'Content-Type': "application/json",
    };
    try {
      // ✅ Hitung total harga dari items
      int totalPrice = 0;
      if (dataRequest is Map && dataRequest.containsKey('pesan')) {
        // Format: {"pesan": [items]}
        final items = dataRequest['pesan'] as List;
        for (var item in items) {
          if (item is Map) {
            final price = (item['harga'] as int?) ?? 0;
            final qty = (item['qty'] as int?) ?? 1;
            totalPrice += price * qty;
          }
        }
      } else if (dataRequest is List) {
        // Format: [items] langsung
        for (var item in dataRequest) {
          if (item is Map) {
            final price = (item['harga'] as int?) ?? 0;
            final qty = (item['qty'] as int?) ?? 1;
            totalPrice += price * qty;
          }
        }
      }

      // ✅ Siapkan berbagai format request body yang mungkin diharapkan backend
      final format1Body = json.encode(dataRequest); // Format standar
      final format2Body = json.encode({
        "pesan": dataRequest,
      }); // Format alternatif
      final format3Body = json.encode({
        "checkout_items": dataRequest,
        "total_amount": totalPrice,
      }); // Format dengan total
      final format4Body = json.encode(dataRequest); // Direct array

      print(
        '\n╔════════════════════════════════════════════════════════════════╗',
      );
      print(
        '║                    REQUEST TO SERVER                            ║',
      );
      print(
        '╚════════════════════════════════════════════════════════════════╝',
      );
      print('URL: $uri');
      print('Method: POST');
      print('Token: ${user.token?.substring(0, 20)}...');
      print('Headers: $headers');
      print(
        '\nData Items (${dataRequest.length} items, Total: Rp $totalPrice):',
      );

      print('\nFormat 1 (items wrapper): ');
      print(format1Body);

      var response = await http.post(uri, body: format1Body, headers: headers);

      // ✅ Jika format 1 gagal, coba format 2
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          '\n⚠️ Format 1 failed (${response.statusCode}), trying Format 2 (pesan wrapper)',
        );
        print(format2Body);
        // response = await http.post(uri, body: format2Body, headers: headers);
      }

      print(
        '\n╔════════════════════════════════════════════════════════════════╗',
      );
      print(
        '║                   RESPONSE FROM SERVER                          ║',
      );
      print(
        '╚════════════════════════════════════════════════════════════════╝',
      );
      print('Final Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('\nResponse Body:');
      print(response.body);
      print(
        '╔════════════════════════════════════════════════════════════════╗\n',
      );
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('\nResponse Body:');
      print(response.body);
      print(
        '╔════════════════════════════════════════════════════════════════╗\n',
      );

      // ✅ Cek apakah response adalah HTML (error page)
      if (response.body.trim().startsWith('<')) {
        print('❌ ERROR: Server mengembalikan HTML, bukan JSON');
        print(
          'Kemungkinan: URL salah, endpoint tidak ditemukan, atau server error',
        );
        print('Full response: ${response.body}');
        return ResponseDataMap(
          status: false,
          message:
              'Server error: Endpoint tidak ditemukan atau server sedang error. '
              'Status: ${response.statusCode}',
        );
      }

      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('❌ ERROR: Gagal parse JSON: $e');
        print('Response: ${response.body}');
        return ResponseDataMap(
          status: false,
          message: 'Response server tidak valid: ${e.toString()}',
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('\n✅ SUCCESS: Request diterima server (${response.statusCode})');
        print('Response Data: $data');

        if (data["status"] == true) {
          print('✅ Status: True - Transaksi berhasil disimpan');

          // ✅ SIMPAN KE DATABASE LOKAL
          final dbHelper = Dbhelper();

          // Extract total harga dari response API
          int? totalFromApi;
          if (data["data"]?["total_harga"] != null) {
            totalFromApi = (data["data"]?["total_harga"] as num?)?.toInt();
          } else if (data["data"]?["total_amount"] != null) {
            totalFromApi = (data["data"]?["total_amount"] as num?)?.toInt();
          } else if (data["data"]?["jumlah"] != null) {
            totalFromApi = (data["data"]?["jumlah"] as num?)?.toInt();
          }

          print('💾 Saving transaction with total: $totalFromApi');

          final transaction = Transaction(
            idTransaksi: data["data"]?["id_transaksi"] as int? ?? 0,
            namaUser: data["data"]?["nama_user"] as String? ?? 'Unknown',
            tglTransaksi:
                data["data"]?["tgl_transaksi"] as String? ??
                DateTime.now().toString(),
            detail: data["data"]?["detail"] as List?,
            totalHargaFromApi:
                totalFromApi ?? totalPrice, // Fallback ke totalPrice dari items
            status: 'completed',
            catatan: data["message"] ?? "Transaksi berhasil",
          );

          final savedTransaction = await dbHelper.insertTransaction(
            transaction,
          );
          if (savedTransaction != null) {
            print(
              '✅ Transaksi disimpan ke database lokal - ID: ${savedTransaction.idTransaksi}, Total: ${savedTransaction.getTotalHarga()}',
            );
          } else {
            print('⚠️ Gagal menyimpan transaksi ke database lokal');
          }

          return ResponseDataMap(
            status: true,
            message: data["message"] ?? "Transaksi berhasil",
            data: data["data"],
          );
        } else {
          print(
            '⚠️ Status: False - Backend tidak bisa menyimpan/menemukan data',
          );
          print('Message dari backend: ${data["message"]}');
          print('Data response: ${data["data"]}');
          print('Full response data: $data');

          // ✅ Debugging info untuk frontend developer
          String debugMsg =
              '''


Response dari backend:
- Message: ${data["message"]}
- Data: ${data["data"]}
- Errors: ${data["errors"] ?? 'none'}
          ''';

          print(debugMsg);

          return ResponseDataMap(
            status: false,
            message:
                data["message"] ??
                "Data tidak ditemukan - check console untuk debugging info",
          );
        }
      } else if (response.statusCode == 500) {
        // ✅ HTTP 500: Backend error
        print('❌ HTTP 500: Backend Error');
        print('Response data: $data');

        String errorMsg = data["message"] ?? "Server sedang mengalami error";
        if (data["errors"] != null) {
          print('Backend errors: ${data["errors"]}');
          errorMsg = data["errors"].toString();
        }

        return ResponseDataMap(
          status: false,
          message:
              'Backend Error: $errorMsg. '
              'Silakan check struktur data atau hubungi backend developer.',
        );
      } else if (response.statusCode == 422) {
        // ✅ HTTP 422: Validation error
        print('❌ HTTP 422: Validation Error');
        String errorMsg = "Validasi gagal: ";
        if (data["message"] is String) {
          errorMsg += data["message"];
        } else if (data["errors"] != null) {
          errorMsg += data["errors"].toString();
        }
        return ResponseDataMap(status: false, message: errorMsg);
      } else if (response.statusCode == 400) {
        // ✅ HTTP 400: Bad request
        print('❌ HTTP 400: Bad Request');
        String errorMsg = data["message"] ?? "Request tidak valid";
        if (data["errors"] != null) {
          print('Validation errors: ${data["errors"]}');
          errorMsg = data["errors"].toString();
        }
        return ResponseDataMap(status: false, message: errorMsg);
      } else {
        // Handle error responses
        String errorMessage = "Gagal dengan error code ${response.statusCode}";

        if (data is Map && data.containsKey("message")) {
          if (data["message"] is List) {
            errorMessage = data["message"].join(", ");
          } else {
            errorMessage = data["message"].toString();
          }
        }

        print('❌ Server returned error: $errorMessage');
        return ResponseDataMap(status: false, message: errorMessage);
      }
    } catch (e) {
      print("Fatal Error: $e");
      return ResponseDataMap(
        status: false,
        message: "Terjadi kesalahan: ${e.toString()}",
      );
    }
  }

  Future<List<dynamic>> getHistory() async {
    var uri = Uri.parse("${url.BaseUrl}/user/history_trans");
    var user = await userLogin.getUserLogin();

    if (user.status == false) return [];

    Map<String, String> headers = {
      "Authorization": 'Bearer ${user.token}',
      'Content-Type': "application/json",
    };

    try {
      var response = await http.get(uri, headers: headers);

      print('╔════════════════════════════════════════════╗');
      print('║          HISTORY RESPONSE                  ║');
      print('╚════════════════════════════════════════════╝');
      print('Status Code: ${response.statusCode}');
      print('Response Body:');
      print(response.body);
      print('════════════════════════════════════════════');

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data["status"] == true) {
          final items = data["data"] ?? [];
          print('\n📋 Total items: ${items.length}');

          // ✅ Debug setiap item
          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            print('\n📍 Item $i:');
            print('  Keys: ${item.keys.toList()}');
            print('  Data: $item');
          }

          return items;
        }
      }
      return [];
    } catch (e) {
      print("❌ Error get history: $e");
      return [];
    }
  }
}
