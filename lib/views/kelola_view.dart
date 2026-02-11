import 'package:flutter/material.dart';
import 'package:postman/models/response_data_list.dart';
import 'package:postman/widgets/bottom_nav.dart';
import 'package:postman/services/product_service.dart';
import 'package:postman/models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart'; 

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  ProductService productService = ProductService();
  List<Product> products = [];

  bool _isLoading = true;
  String _errorMessage = '';

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
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ResponseDataList<Product> response = await productService
          .getProducts();

      if (response.success) {
        setState(() {
          products = response.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Gagal mengambil data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavHeight = 60.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
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
              _fetchProducts();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Container(
          padding: EdgeInsets.only(
           
          ),
          child: _buildBody(),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 50), 
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green[800],
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            'Tambah Barang',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () => _showForm(null),
        ),
      ),
      bottomNavigationBar: const BottomNav(1),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Belum ada data barang',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return _buildLocalData();
  }

  Widget _buildLocalData() {
    final filteredList = _getFilteredList();
    final totalBarang = filteredList.length;
    final totalStok = filteredList.fold<int>(
      0,
      (sum, product) => sum + product.stok,
    );
    final totalNilai = filteredList.fold<double>(
      0.0,
      (sum, product) => sum + (product.stok * product.harga),
    );

    return SingleChildScrollView(
      child: Column(
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
                      _formatCurrency(totalNilai.toInt()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
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
                                _selectedKategori = selected ? kategori : "Semua";
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
          if (filteredList.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final product = filteredList[index];
                return _buildBarangCard(product);
              },
            )
          else
            _buildEmptyState(),

         
          const SizedBox(height: 10),
        ],
      ),
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

  Widget _buildBarangCard(Product product) {
    bool stokRendah = product.stok < 10;
    bool hasImage = product.image.isNotEmpty;
    String kategori = "Material Bangunan";
    String supplier = product.namaBarang;
    String satuan = "pcs";

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
        onTap: () => _showDetailBarang(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: hasImage
                      ? Colors.transparent
                      : _getKategoriColor(kategori).withOpacity(0.1),
                ),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageWidget(product.image, kategori),
                      )
                    : _buildPlaceholderIcon(kategori),
              ),
              const SizedBox(width: 12),

           
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product.namaBarang,
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
                            color: _getKategoriColor(kategori).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kategori,
                            style: TextStyle(
                              fontSize: 10,
                              color: _getKategoriColor(kategori),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Supplier: $supplier',
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
                              _formatCurrency(product.harga.toInt()),
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
                                  '${product.stok} $satuan',
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
                                    _showImageDialog(product.image),
                                tooltip: 'Lihat Gambar',
                              ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.blue,
                              onPressed: () => _showForm(product.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              color: Colors.red,
                              onPressed: () => _deleteBarang(product.id),
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

  Widget _buildImageWidget(String imageUrl, String kategori) {
    if (imageUrl.isEmpty || !imageUrl.startsWith("http")) {
      return _buildPlaceholderIcon(kategori);
    }
    
    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getKategoriColor(kategori),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          return _buildPlaceholderIcon(kategori);
        },
      );
    } catch (e) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderIcon(kategori);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getKategoriColor(kategori),
              ),
            ),
          );
        },
      );
    }
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
    return Container(
      padding: const EdgeInsets.all(20),
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
        ],
      ),
    );
  }

  List<Product> _getFilteredList() {
    List<Product> result = List.from(products);


    if (_searchController.text.isNotEmpty) {
      result = result.where((product) {
        return product.namaBarang.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            product.deskripsi.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );
      }).toList();
    }

    
    if (_showStokRendah) {
      result = result.where((product) => product.stok < 10).toList();
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
                  child: _buildImageWidget(imageUrl, "Material Bangunan"),
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
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
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
                    items: _kategoriList
                        .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(
                        () => _selectedKategori = value!,
                      );
                      setState(() {});
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Stok rendah (<10)'),
                    value: _showStokRendah,
                    onChanged: (value) {
                      setDialogState(() => _showStokRendah = value);
                      setState(() {});
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
                  child: const Text('Reset'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Terapkan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDetailBarang(Product product) {
    bool stokRendah = product.stok < 10;
    bool hasImage = product.image.isNotEmpty;
    String kategori = "Material Bangunan";
    String supplier = "Supplier";
    String satuan = "pcs";

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
                  child: _buildImageWidget(product.image, kategori),
                ),
              ),

            Row(
              children: [
                if (!hasImage)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getKategoriColor(kategori).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getKategoriIcon(kategori),
                      color: _getKategoriColor(kategori),
                      size: 32,
                    ),
                  ),
                if (!hasImage) const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.namaBarang,
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
                          color: _getKategoriColor(kategori).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          kategori,
                          style: TextStyle(
                            color: _getKategoriColor(kategori),
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
            _buildDetailItem(Icons.description, 'Deskripsi', product.deskripsi),
            _buildDetailItem(Icons.business, 'Supplier', supplier),
            _buildDetailItem(
              Icons.inventory,
              'Stok',
              '${product.stok} $satuan',
            ),
            _buildDetailItem(
              Icons.attach_money,
              'Harga',
              _formatCurrency(product.harga.toInt()),
            ),

       
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
                            onTap: () => _showImageDialog(product.image),
                            child: Text(
                              product.image.length > 50
                                  ? '${product.image.substring(0, 50)}...'
                                  : product.image,
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


            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double percent = product.stok <= 0
                      ? 0
                      : (product.stok / 100).clamp(0.0, 1.0);

                  return Container(
                    width: constraints.maxWidth * percent,
                    decoration: BoxDecoration(
                      color: stokRendah ? Colors.orange : Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
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
                    onPressed: () => _showForm(product.id),
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
    final TextEditingController namaController = TextEditingController();
    final TextEditingController stokController = TextEditingController();
    final TextEditingController satuanController = TextEditingController(
      text: "pcs",
    );
    final TextEditingController hargaController = TextEditingController();
    final TextEditingController kategoriController = TextEditingController(
      text: "Material Bangunan",
    );
    final TextEditingController supplierController = TextEditingController(
      text: "Supplier",
    );
    final TextEditingController lokasiController = TextEditingController(
      text: "Gudang Utama",
    );
    final TextEditingController gambarController = TextEditingController();
    final TextEditingController deskripsiController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                    id == null ? "Tambah Barang Baru" : "Edit Barang",
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
              const SizedBox(height: 10),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (gambarController.text.isNotEmpty)
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImageWidget(
                                gambarController.text, "Material Bangunan"),
                          ),
                        ),

                      const SizedBox(height: 15),
                      TextField(
                        controller: namaController,
                        decoration: const InputDecoration(
                          labelText: "Nama Barang",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.construction),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: deskripsiController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: "Deskripsi",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stokController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Stok",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: satuanController,
                              decoration: const InputDecoration(
                                labelText: "Satuan",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: hargaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Harga (Rp)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: gambarController,
                        decoration: const InputDecoration(
                          labelText: "Link Gambar (URL)",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: (value) {
                          setModalState(() {});
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[800],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    _saveBarang(
                      id: id,
                      nama: namaController.text,
                      deskripsi: deskripsiController.text,
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
                    id == null ? "TAMBAH BARANG" : "UPDATE DATA",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveBarang({
    int? id,
    required String nama,
    required String deskripsi,
    required int stok,
    required String satuan,
    required int harga,
    required String kategori,
    required String supplier,
    required String lokasi,
    required String gambar,
  }) async {
    if (nama.isEmpty || harga <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga harus diisi')),
      );
      return;
    }

    _fetchProducts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            id == null
                ? 'Barang berhasil ditambahkan'
                : 'Barang berhasil diupdate',
          ),
        ),
      );
    }
  }

  Future<void> _deleteBarang(int id) async {
    _fetchProducts();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Barang berhasil dihapus')),
      );
    }
  }
}