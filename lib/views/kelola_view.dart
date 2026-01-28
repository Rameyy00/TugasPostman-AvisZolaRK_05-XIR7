import 'package:flutter/material.dart';
import 'package:postman/widgets/bottom_nav.dart';

class KelolaView extends StatefulWidget {
  const KelolaView({super.key});

  @override
  State<KelolaView> createState() => _KelolaViewState();
}

class _KelolaViewState extends State<KelolaView> {
  List<Map<String, dynamic>> _barangList = [
    {
      "id": 1,
      "nama": "Semen Tiga Roda 40kg",
      "stok": 150,
      "satuan": "sak",
      "harga": 65000,
      "kategori": "Material Bangunan",
      "supplier": "Supplier A",
      "lokasi": "Gudang Utama",
      "gambar":
          "https://images.tokopedia.net/img/cache/700/VqbcmM/2021/1/26/2a1179ac-b77e-4139-9a0e-fd1ef262aefc.jpg", // Link gambar
    },
    {
      "id": 2,
      "nama": "Cat Tembok Dulux",
      "stok": 75,
      "satuan": "kaleng",
      "harga": 185000,
      "kategori": "Cat & Pelapis",
      "supplier": "Supplier B",
      "lokasi": "Rak Cat",
      "gambar":
          "https://images.tokopedia.net/img/cache/700/VqbcmM/2022/3/29/18d556a3-45dd-428d-8494-c08f2df91bd6.jpg",
    },
    {
      "id": 3,
      "nama": "Paku Beton 3 inch",
      "stok": 5000,
      "satuan": "kg",
      "harga": 25000,
      "kategori": "Perkakas",
      "supplier": "Supplier C",
      "lokasi": "Rak Perkakas",
      "gambar":
          "https://images.tokopedia.net/img/cache/700/hDjmkQ/2020/11/30/2a8a491e-9f99-4402-94ac-736b26af366d.jpg",
    },
    {
      "id": 4,
      "nama": "Keramik 40x40 Granit",
      "stok": 800,
      "satuan": "keping",
      "harga": 45000,
      "kategori": "Lantai & Dinding",
      "supplier": "Supplier D",
      "lokasi": "Gudang Keramik",
      "gambar":
          "https://images.tokopedia.net/img/cache/700/product-1/2020/6/30/68650798/68650798_8d0bcb81-0396-45ac-8d2a-cbc6764906e2_700_700.jpg",
    },
    {
      "id": 5,
      "nama": "Besi Beton 8mm",
      "stok": 5,
      "satuan": "batang",
      "harga": 85000,
      "kategori": "Material Bangunan",
      "supplier": "Supplier E",
      "lokasi": "Gudang Besi",
      "gambar": "", // Kosong untuk demo
    },
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedKategori = "Semua";
  List<String> _kategoriList = [
    "Semua",
    "Material Bangunan",
    "Cat & Pelapis",
    "Perkakas",
    "Lantai & Dinding",
  ];
  bool _showStokRendah = false;

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();
    final totalBarang = filteredList.length;
    final totalStok = filteredList.fold<int>(
      0,
      (sum, item) => sum + (item['stok'] as int),
    );
    final totalNilai = filteredList.fold<double>(
      0.0,
      (sum, item) => sum + (item['stok'] * item['harga']),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Barang Bangunan'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedKategori = "Semua";
                _showStokRendah = false;
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Header dengan statistik
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(
                      Icons.inventory,
                      'Total',
                      totalBarang.toString(),
                    ),
                    _buildStatItem(Icons.layers, 'Stok', totalStok.toString()),
                    _buildStatItem(
                      Icons.attach_money,
                      'Nilai',
                      _formatCurrency(totalNilai as int),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari barang...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _kategoriList.map((kategori) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(kategori),
                            selected: _selectedKategori == kategori,
                            onSelected: (selected) {
                              setState(() {
                                _selectedKategori = selected
                                    ? kategori
                                    : "Semua";
                              });
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.green[100],
                            labelStyle: TextStyle(
                              color: _selectedKategori == kategori
                                  ? Colors.green[800]
                                  : Colors.grey[700],
                              fontWeight: _selectedKategori == kategori
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.warning,
                    color: _showStokRendah ? Colors.orange[800] : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _showStokRendah = !_showStokRendah;
                    });
                  },
                  tooltip: 'Tampilkan stok rendah',
                ),
              ],
            ),
          ),

          // List Barang
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final barang = filteredList[index];
                      return _buildBarangCard(barang);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Barang',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _showForm(null),
      ),
      bottomNavigationBar: const BottomNav(1),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.green[800], size: 20),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
        ),
      ],
    );
  }

  Widget _buildBarangCard(Map<String, dynamic> barang) {
    bool stokRendah = barang['stok'] < 10;
    bool hasImage =
        barang['gambar'] != null && barang['gambar'].toString().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: stokRendah ? Colors.orange : Colors.grey.shade200,
          width: stokRendah ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showDetailBarang(barang),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Gambar barang atau icon default
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: hasImage
                      ? Colors.transparent
                      : _getKategoriColor(barang['kategori']).withOpacity(0.1),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          barang['gambar'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderIcon(barang['kategori']);
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            );
                          },
                        ),
                      )
                    : _buildPlaceholderIcon(barang['kategori']),
              ),
              const SizedBox(width: 12),

              // Info Barang
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            barang['nama'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getKategoriColor(
                              barang['kategori'],
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            barang['kategori'],
                            style: TextStyle(
                              fontSize: 10,
                              color: _getKategoriColor(barang['kategori']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supplier: ${barang['supplier']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatCurrency(barang['harga']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory,
                                  size: 14,
                                  color: stokRendah
                                      ? Colors.orange
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${barang['stok']} ${barang['satuan']}',
                                  style: TextStyle(
                                    color: stokRendah
                                        ? Colors.orange[800]
                                        : Colors.grey[700],
                                    fontWeight: stokRendah
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            if (hasImage)
                              IconButton(
                                icon: const Icon(Icons.image, size: 18),
                                color: Colors.blue,
                                onPressed: () =>
                                    _showImageDialog(barang['gambar']),
                                tooltip: 'Lihat Gambar',
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.blue,
                              onPressed: () => _showForm(barang['id']),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _deleteBarang(barang['id']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon(String kategori) {
    return Center(
      child: Icon(
        _getKategoriIcon(kategori),
        color: _getKategoriColor(kategori),
        size: 30,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchController.text.isNotEmpty
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isNotEmpty
                ? 'Barang tidak ditemukan'
                : 'Belum ada data barang',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 10),
          if (_searchController.text.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear),
              label: const Text('Reset Pencarian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
            ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => _showForm(null),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Barang Baru'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredList() {
    List<Map<String, dynamic>> result = List.from(_barangList);

    // Filter pencarian
    if (_searchController.text.isNotEmpty) {
      result = result.where((barang) {
        return barang['nama'].toString().toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            barang['kategori'].toString().toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            barang['supplier'].toString().toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    // Filter kategori
    if (_selectedKategori != "Semua") {
      result = result
          .where((barang) => barang['kategori'] == _selectedKategori)
          .toList();
    }

    // Filter stok rendah
    if (_showStokRendah) {
      result = result.where((barang) => barang['stok'] < 10).toList();
    }

    return result;
  }

  Color _getKategoriColor(String kategori) {
    switch (kategori) {
      case 'Material Bangunan':
        return Colors.blue;
      case 'Cat & Pelapis':
        return Colors.green;
      case 'Perkakas':
        return Colors.orange;
      case 'Lantai & Dinding':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getKategoriIcon(String kategori) {
    switch (kategori) {
      case 'Material Bangunan':
        return Icons.construction;
      case 'Cat & Pelapis':
        return Icons.format_paint;
      case 'Perkakas':
        return Icons.build;
      case 'Lantai & Dinding':
        return Icons.square_foot;
      default:
        return Icons.category;
    }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Gambar Barang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text('Gagal memuat gambar'),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Kategori:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: _selectedKategori,
              isExpanded: true,
              items: _kategoriList.map((kategori) {
                return DropdownMenuItem(value: kategori, child: Text(kategori));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedKategori = value!;
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Tampilkan stok rendah (<10)'),
              value: _showStokRendah,
              onChanged: (value) {
                setState(() {
                  _showStokRendah = value;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedKategori = "Semua";
                _showStokRendah = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Reset Filter'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: const Text(
              'Terapkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailBarang(Map<String, dynamic> barang) {
    bool stokRendah = barang['stok'] < 10;
    bool hasImage =
        barang['gambar'] != null && barang['gambar'].toString().isNotEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar barang utama
            if (hasImage)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    barang['gambar'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getKategoriIcon(barang['kategori']),
                              size: 60,
                              color: _getKategoriColor(barang['kategori']),
                            ),
                            const SizedBox(height: 10),
                            const Text('Gambar tidak tersedia'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

            Row(
              children: [
                if (!hasImage)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getKategoriColor(
                        barang['kategori'],
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getKategoriIcon(barang['kategori']),
                      color: _getKategoriColor(barang['kategori']),
                      size: 32,
                    ),
                  ),
                if (!hasImage) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        barang['nama'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getKategoriColor(
                            barang['kategori'],
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          barang['kategori'],
                          style: TextStyle(
                            color: _getKategoriColor(barang['kategori']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailItem(Icons.business, 'Supplier', barang['supplier']),
            _buildDetailItem(Icons.location_on, 'Lokasi', barang['lokasi']),
            _buildDetailItem(
              Icons.inventory,
              'Stok',
              '${barang['stok']} ${barang['satuan']}',
            ),
            _buildDetailItem(
              Icons.attach_money,
              'Harga',
              _formatCurrency(barang['harga']),
            ),

            // Link gambar jika ada
            if (hasImage)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.link, color: Colors.grey, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Link Gambar',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => _showImageDialog(barang['gambar']),
                            child: Text(
                              barang['gambar'].length > 50
                                  ? '${barang['gambar'].substring(0, 50)}...'
                                  : barang['gambar'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Progress bar stok
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                children: [
                  Container(
                    height: 8,
                    width:
                        (barang['stok'] / 100) *
                        MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: stokRendah ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              stokRendah ? '⚠️ Stok rendah, segera restok!' : 'Stok aman',
              style: TextStyle(
                color: stokRendah ? Colors.orange[800] : Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showForm(barang['id']),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Barang'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tutup'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showForm(int? id) {
    Map<String, dynamic>? barang;
    if (id != null) {
      barang = _barangList.firstWhere((b) => b['id'] == id);
    }

    final TextEditingController namaController = TextEditingController(
      text: barang?['nama'],
    );
    final TextEditingController stokController = TextEditingController(
      text: barang?['stok'].toString(),
    );
    final TextEditingController satuanController = TextEditingController(
      text: barang?['satuan'],
    );
    final TextEditingController hargaController = TextEditingController(
      text: barang?['harga'].toString(),
    );
    final TextEditingController kategoriController = TextEditingController(
      text: barang?['kategori'],
    );
    final TextEditingController supplierController = TextEditingController(
      text: barang?['supplier'],
    );
    final TextEditingController lokasiController = TextEditingController(
      text: barang?['lokasi'],
    );
    final TextEditingController gambarController = TextEditingController(
      text: barang?['gambar'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  barang == null ? "Tambah Barang Baru" : "Edit Barang",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Form fields
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Preview gambar jika ada
                    if (gambarController.text.isNotEmpty)
                      Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            gambarController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Link gambar tidak valid',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    TextField(
                      controller: namaController,
                      decoration: const InputDecoration(
                        labelText: "Nama Barang",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.construction),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stokController,
                            decoration: const InputDecoration(
                              labelText: "Stok",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: satuanController,
                            decoration: const InputDecoration(
                              labelText: "Satuan",
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.scale),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: hargaController,
                      decoration: const InputDecoration(
                        labelText: "Harga (Rp)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: kategoriController,
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.category),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_drop_down),
                          onPressed: () {
                            _showKategoriPicker(kategoriController);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: supplierController,
                      decoration: const InputDecoration(
                        labelText: "Supplier",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: lokasiController,
                      decoration: const InputDecoration(
                        labelText: "Lokasi Gudang",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: gambarController,
                      decoration: const InputDecoration(
                        labelText: "Link Gambar (URL)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                        hintText: "https://example.com/gambar.jpg",
                        helperText: "Masukkan link gambar dari internet",
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      _saveBarang(
                        id: id,
                        nama: namaController.text,
                        stok: int.tryParse(stokController.text) ?? 0,
                        satuan: satuanController.text,
                        harga: int.tryParse(hargaController.text) ?? 0,
                        kategori: kategoriController.text,
                        supplier: supplierController.text,
                        lokasi: lokasiController.text,
                        gambar: gambarController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      barang == null ? "TAMBAH BARANG" : "UPDATE",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showKategoriPicker(TextEditingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ..._kategoriList.where((k) => k != "Semua").map((kategori) {
              return ListTile(
                leading: Icon(
                  _getKategoriIcon(kategori),
                  color: _getKategoriColor(kategori),
                ),
                title: Text(kategori),
                onTap: () {
                  controller.text = kategori;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _saveBarang({
    int? id,
    required String nama,
    required int stok,
    required String satuan,
    required int harga,
    required String kategori,
    required String supplier,
    required String lokasi,
    required String gambar,
  }) {
    setState(() {
      if (id == null) {
        // Tambah baru
        int newId = _barangList.isEmpty ? 1 : _barangList.last['id'] + 1;
        _barangList.add({
          "id": newId,
          "nama": nama,
          "stok": stok,
          "satuan": satuan,
          "harga": harga,
          "kategori": kategori,
          "supplier": supplier,
          "lokasi": lokasi,
          "gambar": gambar,
        });
      } else {
        // Edit existing
        int index = _barangList.indexWhere((b) => b['id'] == id);
        if (index != -1) {
          _barangList[index] = {
            "id": id,
            "nama": nama,
            "stok": stok,
            "satuan": satuan,
            "harga": harga,
            "kategori": kategori,
            "supplier": supplier,
            "lokasi": lokasi,
            "gambar": gambar,
          };
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          id == null
              ? "✅ Barang berhasil ditambahkan"
              : "✅ Barang berhasil diperbarui",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteBarang(int id) {
    final barang = _barangList.firstWhere((b) => b['id'] == id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus barang ini?'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Tampilkan gambar thumbnail jika ada
                  if (barang['gambar'] != null &&
                      barang['gambar'].toString().isNotEmpty)
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.grey[200],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          barang['gambar'],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              _getKategoriIcon(barang['kategori']),
                              color: Colors.grey,
                            );
                          },
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          barang['nama'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Kategori: ${barang['kategori']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _barangList.removeWhere((barang) => barang['id'] == id);
              });
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Barang berhasil dihapus'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('HAPUS', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
