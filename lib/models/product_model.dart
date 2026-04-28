class Product {
  final int? id; // nullable untuk produk baru
  final String namaBarang;
  final String deskripsi;
  final int harga; // API mengembalikan harga sebagai integer
  final int stok;
  final String? image; // URL lengkap

  static const String imageBaseUrl = "https://learn.smktelkom-mlg.sch.id/toko";

  Product({
    this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    final rawImage = json['image']?.toString();
    if (rawImage != null && rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        imageUrl = rawImage;
      } else {
        final path = rawImage.startsWith('/')
            ? rawImage.substring(1)
            : rawImage;
        imageUrl = "$imageBaseUrl/$path";
      }
    }

    // ✅ DEBUG: Print semua field dari response dengan detail
    print('=== PRODUCT FROM JSON ===');
    print('All Keys: ${json.keys.toList()}');
    print('Raw JSON: $json');

    // ✅ PENTING: Coba berbagai kemungkinan nama field untuk ID
    int? productId;

    // Try 1: Direct 'id'
    productId = json['id'] as int?;
    print('Try 1 - id: $productId');

    // Try 2: 'product_id'
    if (productId == null) {
      productId = json['product_id'] as int?;
      print('Try 2 - product_id: $productId');
    }

    // Try 3: 'barang_id'
    if (productId == null) {
      productId = json['barang_id'] as int?;
      print('Try 3 - barang_id: $productId');
    }

    // Try 4: Parse string to int
    if (productId == null && json['id'] != null) {
      productId = int.tryParse(json['id'].toString());
      print('Try 4 - parse id as string: $productId');
    }

    // Try 5: Hash dari nama_barang (FALLBACK jika benar-benar tidak ada ID)
    if (productId == null) {
      String namaBarang = json['nama_barang']?.toString() ?? '';
      productId = namaBarang.hashCode.abs() % 1000000;
      print(
        '❌ WARNING: No ID field found! Using hash fallback: $productId (dari: $namaBarang)',
      );
    }

    print('Final Product ID: $productId');
    print('==========================\n');

    return Product(
      id: productId,
      namaBarang: json['nama_barang'] ?? 'Unknown',
      deskripsi: json['deskripsi'] ?? '',
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      image: imageUrl,
    );
  }
}
