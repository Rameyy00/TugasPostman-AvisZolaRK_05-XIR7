class Transaction {
  int? idTransaksi;
  String? namaUser;
  String? tglTransaksi;
  List<dynamic>? detail; // Detail items dari transaksi
  int? totalHargaFromApi; // Total harga dari API response (jika tersedia)
  String? status;
  String? catatan;

  Transaction({
    this.idTransaksi,
    this.namaUser,
    this.tglTransaksi,
    this.detail,
    this.totalHargaFromApi,
    this.status,
    this.catatan,
  });

  // Hitung total harga dari detail items atau dari API
  int getTotalHarga() {
  if (totalHargaFromApi != null && totalHargaFromApi! > 0) {
    return totalHargaFromApi!;
  }

  if (detail == null || detail!.isEmpty) return 0;

  int total = 0;
  for (var item in detail!) {
    if (item is Map) {
      final harga = (item['harga_beli'] as num?)?.toInt() ?? 0; // ← ganti ini
      final qty = (item['qty'] as num?)?.toInt() ??
                  (item['quantity'] as num?)?.toInt() ?? 1;
      total += harga * qty;
    }
  }
  return total;
}

  // Convert ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': idTransaksi,
      'nama_user': namaUser ?? '',
      'tanggal': tglTransaksi ?? DateTime.now().toString(),
      'total_harga': getTotalHarga(),
      'status': status ?? 'completed',
      'catatan': catatan ?? '',
    };
  }

  // Convert dari Map (dari database)
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      idTransaksi: map['id'] as int?,
      namaUser: map['nama_user'] as String?,
      tglTransaksi: map['tanggal'] as String?,
      totalHargaFromApi:
          map['total_harga'] as int?, // ✅ Restore total dari database
      status: map['status'] as String?,
      catatan: map['catatan'] as String?,
    );
  }

  // Convert dari API response
  factory Transaction.fromApi(Map<String, dynamic> json) {
    // ✅ Extract total dari berbagai kemungkinan field
    int? totalHarga;
    if (json['total_harga'] != null) {
      totalHarga = (json['total_harga'] as num?)?.toInt();
    } else if (json['total_amount'] != null) {
      totalHarga = (json['total_amount'] as num?)?.toInt();
    } else if (json['jumlah'] != null) {
      totalHarga = (json['jumlah'] as num?)?.toInt();
    }

    print(
      '📊 Transaction.fromApi() - ID: ${json['id_transaksi']}, Total dari API: $totalHarga, Detail: ${json['detail']}',
    );

    return Transaction(
      idTransaksi: json['id_transaksi'] as int?,
      namaUser: json['nama_user'] as String?,
      tglTransaksi: json['tgl_transaksi'] as String?,
      detail: json['detail'] as List?,
      totalHargaFromApi: totalHarga,
      status: json['status'] as String? ?? 'completed',
      catatan: json['catatan'] as String?,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $idTransaksi, user: $namaUser, tgl: $tglTransaksi, total: ${getTotalHarga()})';
  }

  // Validasi data
  bool isValid() {
    return idTransaksi != null && getTotalHarga() > 0;
  }
}
