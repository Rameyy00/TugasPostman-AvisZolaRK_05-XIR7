class Product {
  final int? id;              // nullable untuk produk baru
  final String namaBarang;
  final String deskripsi;
  final int harga;            // API mengembalikan harga sebagai integer
  final int stok;
  final String? image;        // URL lengkap

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
        final path = rawImage.startsWith('/') ? rawImage.substring(1) : rawImage;
        imageUrl = "$imageBaseUrl/$path";
      }
    }

    return Product(
      id: json['id'] as int?,
      namaBarang: json['nama_barang'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: int.tryParse(json['harga'].toString()) ?? 0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      image: imageUrl,
    );
  }
}