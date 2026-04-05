import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:postman/models/response_data_list.dart';
import 'package:postman/models/response_data_map.dart';
import 'package:postman/models/product_model.dart';
import 'package:postman/models/user_login.dart';

class ProductService {
  final String baseUrl = "https://learn.smktelkom-mlg.sch.id/toko/api";

  // Helper untuk mendapatkan token
  Future<Map<String, String>> _getHeaders() async {
    final user = await UserLogin().getUserLogin();
    if (!user.status) {
      throw Exception('Token tidak valid atau belum login');
    }
    return {'Authorization': 'Bearer ${user.token}'};
  }

  Future<ResponseDataMap> addProduct(Product product, {File? image}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/admin/insertbarang');
      final request = http.MultipartRequest('POST', uri);

      // Kirim file dengan field 'image' (sesuai Postman)
      if (image != null) {
        // Gunakan fromPath jika path tersedia (mobile & web)
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path, // Path file
          ),
        );
      }

      // Field data dengan snake_case
      request.fields['nama_barang'] = product.namaBarang;
      request.fields['deskripsi'] = product.deskripsi;
      request.fields['harga'] = product.harga.toString();
      request.fields['stok'] = product.stok.toString();

      request.headers.addAll(headers);

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(result.body);
        if (data['status'] == true) {
          return ResponseDataMap(
            status: true,
            message: data['message'] ?? 'Berhasil menambah barang',
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: data['message'] ?? 'Gagal menambah barang',
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: 'Gagal, status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error addProduct: $e');
      return ResponseDataMap(status: false, message: 'Error: ${e.toString()}');
    }
  }

  Future<ResponseDataMap> updateProduct(Product product, {File? image}) async {
    try {
      final headers = await _getHeaders();
      if (product.id == null) {
        return ResponseDataMap(
          status: false,
          message: 'ID produk tidak ditemukan untuk update',
        );
      }
      final uri = Uri.parse('$baseUrl/admin/updatebarang/${product.id}');
      final request = http.MultipartRequest('POST', uri); // API pakai POST

      if (image != null) {
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: image.path.split('/').last,
          ),
        );
      }

      request.fields['nama_barang'] = product.namaBarang;
      request.fields['deskripsi'] = product.deskripsi;
      request.fields['harga'] = product.harga.toString();
      request.fields['stok'] = product.stok.toString();

      request.headers.addAll(headers);

      final response = await request.send();
      final result = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final data = json.decode(result.body);
        if (data['status'] == true) {
          return ResponseDataMap(
            status: true,
            message: data['message'] ?? 'Berhasil update barang',
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: data['message'] ?? 'Gagal update barang',
          );
        }
      } else {
        return ResponseDataMap(
          status: false,
          message: 'Gagal, status ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error updateProduct: $e');
      return ResponseDataMap(status: false, message: 'Error: ${e.toString()}');
    }
  }

  // GET products (tetap sama)
  Future<ResponseDataList<Product>> getProducts() async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/admin/getbarang');
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          List<Product> products = [];
          if (data['data'] != null) {
            products = (data['data'] as List)
                .map((item) => Product.fromJson(item))
                .toList();
          }
          return ResponseDataList(
            success: true,
            message: data['message'] ?? 'Berhasil mengambil data',
            data: products,
          );
        } else {
          return ResponseDataList(
            success: false,
            message: data['message'] ?? 'Gagal mengambil data',
            data: [],
          );
        }
      } else {
        return ResponseDataList(
          success: false,
          message: 'Gagal, status ${response.statusCode}',
          data: [],
        );
      }
    } catch (e) {
      print('Error getProducts: $e');
      return ResponseDataList(
        success: false,
        message: 'Error: ${e.toString()}',
        data: [],
      );
    }
  }

  // Hapus produk
  Future<ResponseDataList> deleteProduct(int id) async {
    try {
      final user = await UserLogin().getUserLogin();
      if (!user.status) {
        return ResponseDataList(
          success: false,
          message: 'Token tidak valid',
          data: [],
        );
      }
      final uri = Uri.parse('$baseUrl/admin/hapusbarang/$id');
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer ${user.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ResponseDataList(
          success: data['status'] == true,
          message: data['message'] ?? '',
          data: [],
        );
      } else {
        return ResponseDataList(
          success: false,
          message: 'Gagal, status ${response.statusCode}',
          data: [],
        );
      }
    } catch (e) {
      return ResponseDataList(
        success: false,
        message: 'Error: ${e.toString()}',
        data: [],
      );
    }
  }
}
