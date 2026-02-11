class Product {
  final int id;
  final String namaBarang;
  final String deskripsi;
  final double harga;
  final int stok;
  final String image;

  static String imageBaseUrl =
      "https://learn.smktelkom-mlg.sch.id/toko";

  Product({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.harga,
    required this.stok,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imageUrl = '';

    if (json['image'] != null && json['image'] != '') {
      if (json['image'].toString().startsWith('http')) {
        imageUrl = json['image'].toString();
      } else {
        String imagePath = json['image'].toString();
        if (imagePath.startsWith('/')) {
          imagePath = imagePath.substring(1);
        }
        imageUrl = "$imageBaseUrl/$imagePath";
      }
    }

    return Product(
      id: json['id'] ?? 0,
      namaBarang: json['nama_barang'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      harga: double.tryParse(json['harga'].toString()) ?? 0.0,
      stok: int.tryParse(json['stok'].toString()) ?? 0,
      image: imageUrl,
    );
  }
}
