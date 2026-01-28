import 'package:flutter/material.dart';
import 'package:postman/widgets/bottom_nav.dart';

class PesanView extends StatefulWidget {
  const PesanView({super.key});

  @override
  State<PesanView> createState() => _PesanViewState();
}

class _PesanViewState extends State<PesanView> {
  // ======================
  // DATA DUMMY PESANAN
  // ======================
  final List<Map<String, dynamic>> _pesananList = [
    {
      "id": 1,
      "nomor_pesanan": "ORD-001",
      "nama_pelanggan": "Budi Santoso",
      "tanggal": "2024-03-15",
      "status": "Pending",
      "total": 1250000,
      "items": [
        {"nama": "Semen 40kg", "qty": 10, "harga": 65000},
        {"nama": "Paku 3 inch", "qty": 5, "harga": 25000},
      ],
      "alamat": "Jl. Merdeka No. 123, Jakarta",
      "telepon": "081234567890",
    },
    {
      "id": 2,
      "nomor_pesanan": "ORD-002",
      "nama_pelanggan": "Siti Aminah",
      "tanggal": "2024-03-14",
      "status": "Diproses",
      "total": 850000,
      "items": [
        {"nama": "Cat Tembok", "qty": 3, "harga": 185000},
        {"nama": "KuCat", "qty": 2, "harga": 25000},
      ],
      "alamat": "Jl. Sudirman No. 456, Bandung",
      "telepon": "082345678901",
    },
    {
      "id": 3,
      "nomor_pesanan": "ORD-003",
      "nama_pelanggan": "Ahmad Wijaya",
      "tanggal": "2024-03-13",
      "status": "Selesai",
      "total": 2250000,
      "items": [
        {"nama": "Keramik 40x40", "qty": 50, "harga": 45000},
      ],
      "alamat": "Jl. Gatot Subroto No. 789, Surabaya",
      "telepon": "083456789012",
    },
    {
      "id": 4,
      "nomor_pesanan": "ORD-004",
      "nama_pelanggan": "Dewi Lestari",
      "tanggal": "2024-03-12",
      "status": "Dibatalkan",
      "total": 500000,
      "items": [
        {"nama": "Besi Beton 8mm", "qty": 5, "harga": 85000},
        {"nama": "Semen 40kg", "qty": 2, "harga": 65000},
      ],
      "alamat": "Jl. Thamrin No. 101, Medan",
      "telepon": "084567890123",
    },
    {
      "id": 5,
      "nomor_pesanan": "ORD-005",
      "nama_pelanggan": "Rudi Hartono",
      "tanggal": "2024-03-11",
      "status": "Pending",
      "total": 3750000,
      "items": [
        {"nama": "Cat Tembok", "qty": 10, "harga": 185000},
        {"nama": "Semen 40kg", "qty": 20, "harga": 65000},
        {"nama": "Paku 3 inch", "qty": 10, "harga": 25000},
      ],
      "alamat": "Jl. Diponegoro No. 222, Semarang",
      "telepon": "085678901234",
    },
  ];

  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = "Semua Status";

  final List<String> _statusList = [
    "Semua Status",
    "Pending",
    "Diproses",
    "Selesai",
    "Dibatalkan",
  ];

  // ======================
  // STATISTIK PESANAN
  // ======================
  Map<String, int> get _statistics {
    return {
      'total': _pesananList.length,
      'pending': _pesananList.where((p) => p['status'] == 'Pending').length,
      'diproses': _pesananList.where((p) => p['status'] == 'Diproses').length,
      'selesai': _pesananList.where((p) => p['status'] == 'Selesai').length,
      'dibatalkan':
          _pesananList.where((p) => p['status'] == 'Dibatalkan').length,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ======================
  // BUILD UI
  // ======================
  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredList();
    final stats = _statistics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Pesanan'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Pesanan',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _tambahPesanan,
            tooltip: 'Tambah Pesanan Baru',
          ),
        ],
      ),
      body: Column(
        children: [
          // ======================
          // HEADER + SEARCH
          // ======================
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green[50],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.shopping_cart,
                      'Total',
                      stats['total'].toString(),
                    ),
                    _buildStatItem(
                      Icons.access_time,
                      'Pending',
                      stats['pending'].toString(),
                    ),
                    _buildStatItem(
                      Icons.autorenew,
                      'Diproses',
                      stats['diproses'].toString(),
                    ),
                    _buildStatItem(
                      Icons.check_circle,
                      'Selesai',
                      stats['selesai'].toString(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari pesanan / pelanggan / telepon...',
                    prefixIcon: const Icon(Icons.search, color: Colors.green),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
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

          // ======================
          // FILTER CHIPS
          // ======================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statusList.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: _selectedFilter == status,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? status : "Semua Status";
                        });
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: _getStatusColor(status),
                      labelStyle: TextStyle(
                        color: _selectedFilter == status
                            ? Colors.white
                            : Colors.grey[700],
                        fontWeight: _selectedFilter == status
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ======================
          // HEADER LIST
          // ======================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filteredList.length} Pesanan Ditemukan',
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

          // ======================
          // LIST PESANAN
          // ======================
          Expanded(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final pesanan = filteredList[index];
                        return _buildPesananCard(pesanan);
                      },
                    ),
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Pesanan Baru',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: _tambahPesanan,
      ),

      // ✅ FIX: halaman pesan harus index 1
      bottomNavigationBar: const BottomNav(1),
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

  Widget _buildPesananCard(Map<String, dynamic> pesanan) {
    final Color statusColor = _getStatusColor(pesanan['status']);
    final Color statusBgColor = statusColor.withOpacity(0.1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDetailPesanan(pesanan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan['nomor_pesanan'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pelanggan: ${pesanan['nama_pelanggan']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(pesanan['status']),
                          color: statusColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pesanan['status'],
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              pesanan['tanggal'],
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.format_list_bulleted,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              '${pesanan['items'].length} item',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Total',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Text(
                        _formatCurrency(pesanan['total']),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDetailPesanan(pesanan),
                      icon: const Icon(Icons.remove_red_eye, size: 16),
                      label: const Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _ubahStatusPesanan(pesanan),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Ubah Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
                : Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            _searchController.text.isNotEmpty
                ? 'Pesanan tidak ditemukan'
                : 'Belum ada pesanan',
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
            onPressed: _tambahPesanan,
            icon: const Icon(Icons.add),
            label: const Text('Buat Pesanan Baru'),
          ),
        ],
      ),
    );
  }

  // ======================
  // HELPERS
  // ======================
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.access_time;
      case 'Diproses':
        return Icons.autorenew;
      case 'Selesai':
        return Icons.check_circle;
      case 'Dibatalkan':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  List<Map<String, dynamic>> _getFilteredList() {
    List<Map<String, dynamic>> result = List.from(_pesananList);

    // Search
    if (_searchController.text.isNotEmpty) {
      final keyword = _searchController.text.toLowerCase();
      result = result.where((pesanan) {
        return pesanan['nomor_pesanan'].toString().toLowerCase().contains(
              keyword,
            ) ||
            pesanan['nama_pelanggan'].toString().toLowerCase().contains(
              keyword,
            ) ||
            pesanan['telepon'].toString().toLowerCase().contains(keyword);
      }).toList();
    }

    // Filter status
    if (_selectedFilter != "Semua Status") {
      result =
          result.where((pesanan) => pesanan['status'] == _selectedFilter).toList();
    }

    // Sort by tanggal terbaru
    result.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

    return result;
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
  }

  // ======================
  // DIALOGS / BOTTOMSHEET
  // ======================
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Status Pesanan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statusList.map((status) {
                return FilterChip(
                  label: Text(status),
                  selected: _selectedFilter == status,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? status : "Semua Status";
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.grey[200],
                  selectedColor: _getStatusColor(status),
                  labelStyle: TextStyle(
                    color: _selectedFilter == status
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = "Semua Status";
              });
              Navigator.pop(context);
            },
            child: const Text('Reset Filter'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: const Text(
              'Tutup',
              style: TextStyle(color: Colors.white),
            ),
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
              'Urutkan Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.blue),
              title: const Text('Tanggal Terbaru'),
              trailing: const Icon(Icons.check, color: Colors.green),
              onTap: () {
                setState(() {
                  _pesananList.sort(
                    (a, b) => b['tanggal'].compareTo(a['tanggal']),
                  );
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_up, color: Colors.green),
              title: const Text('Total Tertinggi'),
              onTap: () {
                setState(() {
                  _pesananList.sort((a, b) => b['total'].compareTo(a['total']));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.trending_down, color: Colors.orange),
              title: const Text('Total Terendah'),
              onTap: () {
                setState(() {
                  _pesananList.sort((a, b) => a['total'].compareTo(b['total']));
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.purple),
              title: const Text('Nama Pelanggan A-Z'),
              onTap: () {
                setState(() {
                  _pesananList.sort(
                    (a, b) =>
                        a['nama_pelanggan'].compareTo(b['nama_pelanggan']),
                  );
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

  void _showDetailPesanan(Map<String, dynamic> pesanan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pesanan['nomor_pesanan'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal: ${pesanan['tanggal']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(pesanan['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(pesanan['status']).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(pesanan['status']),
                      color: _getStatusColor(pesanan['status']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Pesanan',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            pesanan['status'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(pesanan['status']),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _ubahStatusPesanan(pesanan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text(
                        'Ubah Status',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Info Pelanggan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person, 'Nama', pesanan['nama_pelanggan']),
              _buildDetailRow(Icons.phone, 'Telepon', pesanan['telepon']),
              _buildDetailRow(Icons.location_on, 'Alamat', pesanan['alamat']),

              const SizedBox(height: 20),

              const Text(
                'Items Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...pesanan['items'].map<Widget>((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['nama'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${item['qty']} x ${_formatCurrency(item['harga'])}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatCurrency(item['qty'] * item['harga']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pesanan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatCurrency(pesanan['total']),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cetakInvoice(pesanan),
                      icon: const Icon(Icons.print),
                      label: const Text('Cetak Invoice'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _editPesanan(pesanan);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Pesanan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
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

  // ======================
  // ACTIONS
  // ======================
  void _ubahStatusPesanan(Map<String, dynamic> pesanan) {
    final List<String> statusOptions = [
      "Pending",
      "Diproses",
      "Selesai",
      "Dibatalkan",
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ubah Status Pesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...statusOptions.map((status) {
              return ListTile(
                leading: Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                title: Text(status),
                trailing: pesanan['status'] == status
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  setState(() {
                    pesanan['status'] = status;
                  });
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status berhasil diubah menjadi $status'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              );
            }).toList(),
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

  void _tambahPesanan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Pesanan Baru'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fitur tambah pesanan akan segera hadir!'),
              SizedBox(height: 20),
              Icon(Icons.shopping_cart, size: 60, color: Colors.green),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              final newId =
                  _pesananList.isEmpty ? 1 : _pesananList.last['id'] + 1;

              final now = DateTime.now();
              final formattedDate =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

              setState(() {
                _pesananList.add({
                  "id": newId,
                  "nomor_pesanan":
                      "ORD-${(newId + 100).toString().padLeft(3, '0')}",
                  "nama_pelanggan": "Pelanggan Baru",
                  "tanggal": formattedDate,
                  "status": "Pending",
                  "total": 100000,
                  "items": [
                    {"nama": "Barang Contoh", "qty": 1, "harga": 100000},
                  ],
                  "alamat": "Alamat baru",
                  "telepon": "08123456789",
                });
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil ditambahkan'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: const Text(
              'Tambah Dummy',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _editPesanan(Map<String, dynamic> pesanan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pesanan'),
        content: Text('Edit pesanan ${pesanan['nomor_pesanan']}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                pesanan['nama_pelanggan'] =
                    '${pesanan['nama_pelanggan']} (Edited)';
              });

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pesanan berhasil diupdate'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cetakInvoice(Map<String, dynamic> pesanan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mencetak invoice ${pesanan['nomor_pesanan']}'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}
