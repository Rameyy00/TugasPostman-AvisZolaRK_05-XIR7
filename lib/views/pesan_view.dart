import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:postman/models/cart.dart';
import 'package:postman/models/product_model.dart';
import 'package:postman/services/user.dart';
import 'package:postman/views/cartscreen.dart';
import 'package:postman/widgets/bottom_nav.dart';
import 'package:postman/controllers/cartProvider.dart';
// sesuaikan path import CartScreen

class PesanView extends StatefulWidget {
  const PesanView({super.key});

  @override
  State<PesanView> createState() => _PesanViewState();
}

class _PesanViewState extends State<PesanView> {
  List<Product> _productList = [];
  List<Product> _filteredList = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "Semua";
  final List<String> _filterOptions = ["Semua", "Stok > 0", "Stok Habis"];

  late CartProvider cartProvider;

  // Statistik sederhana untuk user
  Map<String, int> get _statistics {
    return {
      'total': _productList.length,
      'tersedia': _productList.where((p) => p.stok > 0).length,
      'habis': _productList.where((p) => p.stok == 0).length,
    };
  }

  @override
  void initState() {
    super.initState();
    cartProvider = CartProvider();
    cartProvider.getData(); // muat data keranjang
    _fetchProductsFromApi();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Ambil data produk dari API via UserService
  Future<void> _fetchProductsFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('\n=== FETCH PRODUCTS FROM API ===');
      UserService userService = UserService();
      final response = await userService.getBarangUser();

      print('API Response Success: ${response.success}');
      print('API Response Message: ${response.message}');
      print('API Response Data Length: ${response.data.length}');

      if (response.success) {
        List<Product> products = [];
        int validProducts = 0;
        int invalidProducts = 0;

        for (int i = 0; i < response.data.length; i++) {
          try {
            print('\n--- Parsing Product $i ---');
            Product product = Product.fromJson(response.data[i]);
            print(
              '✅ Product $i parsed successfully: ${product.namaBarang}, ID: ${product.id}',
            );

            if (product.id != null && product.id! > 0) {
              validProducts++;
            } else {
              invalidProducts++;
              print('⚠️ WARNING: Product has null or invalid ID');
            }

            products.add(product);
          } catch (e) {
            invalidProducts++;
            print('❌ ERROR parsing product $i: $e');
            print('Raw data: ${response.data[i]}');
          }
        }

        print('\n=== SUMMARY ===');
        print('Total products: ${response.data.length}');
        print('Valid products (with ID): $validProducts');
        print('Invalid products (null ID): $invalidProducts');
        print('=================\n');

        setState(() {
          _productList = products;
          _applyFiltersAndSearch();
          _isLoading = false;
        });
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      print('❌ ERROR: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Filter dan pencarian
  void _applyFiltersAndSearch() {
    List<Product> result = List.from(_productList);

    // Pencarian
    if (_searchController.text.isNotEmpty) {
      final keyword = _searchController.text.toLowerCase();
      result = result.where((product) {
        return product.namaBarang.toLowerCase().contains(keyword) ||
            product.deskripsi.toLowerCase().contains(keyword);
      }).toList();
    }

    // Filter stok
    if (_selectedFilter == "Stok > 0") {
      result = result.where((p) => p.stok > 0).toList();
    } else if (_selectedFilter == "Stok Habis") {
      result = result.where((p) => p.stok == 0).toList();
    } else {
      // default sorting nama A-Z
      result.sort((a, b) => a.namaBarang.compareTo(b.namaBarang));
    }

    setState(() {
      _filteredList = result;
    });
  }

  Future<void> _refreshData() async {
    await _fetchProductsFromApi();
  }

  // Tambah ke keranjang
  void _addToCart(Product product) async {
    print('\n=== ADD TO CART ===');
    print('Product: $product');
    print('Product ID: ${product.id}');
    print('Product ID is null: ${product.id == null}');

    if (product.stok <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok habis, tidak bisa ditambahkan ke keranjang'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Validasi: product ID harus ada dan > 0
    if (product.id == null || product.id! <= 0) {
      print('❌ ERROR: Product ID is null or invalid');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data produk tidak lengkap. Silakan refresh halaman.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ✅ Buat objek Cart dengan productId yang valid
    Cart cartItem = Cart(
      productId: product.id, // Wajib ada dan > 0
      namaBarang: product.namaBarang,
      harga: product.harga,
      image: product.image,
      quantity: 1,
    );

    print('Cart item: $cartItem');
    print('====================\n');

    await cartProvider.addToCart(cartItem);
    setState(() {}); // refresh badge
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.namaBarang} ditambahkan ke keranjang'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ======================
  // WIDGETS
  // ======================
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
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
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
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

  // Card produk dengan tombol beli
  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar produk
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: product.image != null && product.image!.isNotEmpty
                  ? Image.network(
                      product.image!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 40),
                    ),
            ),
            const SizedBox(width: 12),
            // Informasi produk
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.namaBarang,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.deskripsi,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        _formatCurrency(product.harga),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.stok > 0
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Stok: ${product.stok}',
                          style: TextStyle(
                            fontSize: 12,
                            color: product.stok > 0
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Tombol Beli
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: product.stok > 0
                          ? () => _addToCart(product)
                          : null,
                      icon: const Icon(Icons.shopping_cart, size: 16),
                      label: const Text('Beli'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                ? 'Produk tidak ditemukan'
                : 'Belum ada produk',
            style: TextStyle(fontSize: 18, color: Colors.grey[500]),
          ),
          const SizedBox(height: 10),
          if (_searchController.text.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _applyFiltersAndSearch();
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

  // ======================
  // HELPERS
  // ======================
  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // ======================
  // DIALOGS (Filter & Sort)
  // ======================
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pilih filter:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filterOptions.map((filter) {
                return FilterChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? filter : "Semua";
                    });
                    _applyFiltersAndSearch();
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: Colors.green[200],
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = "Semua";
                _applyFiltersAndSearch();
              });
              Navigator.pop(context);
            },
            child: const Text('Reset Filter'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: const Text('Tutup', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Urutkan Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha, color: Colors.blue),
              title: const Text('Nama A-Z'),
              onTap: () {
                setState(() {
                  _filteredList.sort(
                    (a, b) => a.namaBarang.compareTo(b.namaBarang),
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money, color: Colors.green),
              title: const Text('Harga Termurah'),
              onTap: () {
                setState(() {
                  _filteredList.sort((a, b) => a.harga.compareTo(b.harga));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money, color: Colors.orange),
              title: const Text('Harga Termahal'),
              onTap: () {
                setState(() {
                  _filteredList.sort((a, b) => b.harga.compareTo(a.harga));
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================
  // BUILD
  // ======================
  @override
  Widget build(BuildContext context) {
    final stats = _statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Produk',
          ),
          // Badge keranjang
          badges.Badge(
            badgeContent: ListenableBuilder(
              listenable: cartProvider,
              builder: (context, child) {
                return Text(
                  cartProvider.cart.isEmpty ? '0' : '${cartProvider.counter}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 2),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Error: $_errorMessage"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _fetchProductsFromApi,
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Statistik & Pencarian
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green[50],
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            Icons.inventory,
                            'Total Produk',
                            stats['total'].toString(),
                          ),
                          _buildStatItem(
                            Icons.check_circle,
                            'Stok Tersedia',
                            stats['tersedia'].toString(),
                          ),
                          _buildStatItem(
                            Icons.cancel,
                            'Stok Habis',
                            stats['habis'].toString(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => _applyFiltersAndSearch(),
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.green,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    _applyFiltersAndSearch();
                                  },
                                )
                              : null,
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
                // Filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _filterOptions.map((filter) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setState(() {
                                _selectedFilter = selected ? filter : "Semua";
                              });
                              _applyFiltersAndSearch();
                            },
                            backgroundColor: Colors.grey[200],
                            selectedColor: Colors.green[200],
                            labelStyle: TextStyle(
                              color: _selectedFilter == filter
                                  ? Colors.green[800]
                                  : Colors.grey[700],
                              fontWeight: _selectedFilter == filter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Header list
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredList.length} Produk Ditemukan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showSortOptions,
                        icon: const Icon(Icons.sort, size: 16),
                        label: const Text('Urutkan'),
                      ),
                    ],
                  ),
                ),
                // List produk
                Expanded(
                  child: _filteredList.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _filteredList.length,
                            itemBuilder: (context, index) {
                              final product = _filteredList[index];
                              return _buildProductCard(product);
                            },
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNav(1),
    );
  }
}
