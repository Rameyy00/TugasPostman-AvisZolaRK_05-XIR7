class Cart {
  final int? id;
  final int? productId;
  final String? namaBarang;
  final int? harga;
  final String? image;
  int? quantity;

  Cart({
    this.id,
    this.productId,
    this.namaBarang,
    this.harga,
    this.image,
    this.quantity = 1,
  });

  factory Cart.fromMap(Map<String, dynamic> data) {
    return Cart(
      id: data['id'] as int?,
      productId: data['product_id'] as int?,
      namaBarang: data['nama_barang'] as String? ?? 'Produk',
      harga: data['harga'] as int? ?? 0,
      image: data['image'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    // ✅ Menyimpan semua field termasuk product_id
    return {
      'id': id,
      'product_id': productId,
      'nama_barang': namaBarang,
      'harga': harga,
      'image': image,
      'quantity': quantity,
    };
  }

  /// Validasi kelengkapan data untuk checkout
  bool isValid() {
    // ✅ Validasi ketat: semua field wajib ada dan > 0
    return (productId != null && productId! > 0) && // product_id WAJIB dan > 0
        (namaBarang != null && namaBarang!.isNotEmpty) &&
        quantity != null &&
        quantity! > 0 &&
        harga != null &&
        harga! > 0;
  }

  /// Total harga per item
  int get totalPrice => (harga ?? 0) * (quantity ?? 1);

  /// Map untuk dikirim ke API checkout
  Map<String, dynamic> toCheckoutMap() {
    // ✅ Include product_id dan quantity untuk checkout
    return {'product_id': productId, 'quantity': quantity};
  }

  /// Membuat salinan dengan perubahan field tertentu
  Cart copyWith({
    int? id,
    int? productId,
    String? namaBarang,
    int? harga,
    String? image,
    int? quantity,
  }) {
    return Cart(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      namaBarang: namaBarang ?? this.namaBarang,
      harga: harga ?? this.harga,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'Cart{id: $id, productId: $productId, namaBarang: $namaBarang, '
        'harga: $harga, image: $image, quantity: $quantity}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.productId == productId;
  }

  @override
  int get hashCode => productId.hashCode;
}
