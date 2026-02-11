import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:postman/models/response_data_list.dart';
import 'package:postman/models/product_model.dart';

class ProductService {

  final String baseUrl = "https://learn.smktelkom-mlg.sch.id/toko/api";

  Future<ResponseDataList<Product>> getProducts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null || token.isEmpty) {
        return ResponseDataList(
          success: false,
          message: 'Token tidak ditemukan. Silakan login terlebih dahulu.',
          data: [],
        );
      }

      final Uri uri = Uri.parse('$baseUrl/admin/getbarang');

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        return ResponseDataList<Product>.fromJson(
          jsonData,
          (item) => Product.fromJson(item),
        );
      } else if (response.statusCode == 401) {
        return ResponseDataList(
          success: false,
          message: 'Token tidak valid atau telah kadaluarsa',
          data: [],
        );
      } else {
        return ResponseDataList(
          success: false,
          message: 'Gagal mengambil data. Status: ${response.statusCode}',
          data: [],
        );
      }
    } catch (e) {
      print('Error in ProductService.getProducts: $e');
      return ResponseDataList(success: false, message: e.toString(), data: []);
    }
  }
  

}