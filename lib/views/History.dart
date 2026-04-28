import 'package:flutter/material.dart';
import 'package:postman/services/transaksi.dart';
import 'package:postman/services/DBHelper.dart';
import 'package:postman/models/transaction_model.dart';
import 'package:postman/widgets/bottom_nav.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<dynamic> _transactions = [];
  bool _isLoading = true;
  bool _useLocalData = false;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      // ✅ Coba ambil dari server dulu
      final serverData = await Pesan().getHistory();

      if (serverData.isNotEmpty) {
        setState(() {
          _transactions = serverData;
          _useLocalData = false;
          _isLoading = false;
        });
      } else {
        // ✅ Jika server kosong atau error, gunakan data lokal
        await _fetchLocalHistory();
      }
    } catch (e) {
      print('Error fetching from server: $e');
      // ✅ Fallback ke database lokal
      await _fetchLocalHistory();
    }
  }

  Future<void> _fetchLocalHistory() async {
    try {
      final dbHelper = Dbhelper();
      final localData = await dbHelper.getTransactionList();

      setState(() {
        _transactions = localData;
        _useLocalData = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching local history: $e');
      setState(() {
        _transactions = [];
        _isLoading = false;
      });
    }
  }

  /// Refresh data dari server
  Future<void> _refreshFromServer() async {
    await _fetchHistory();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data diperbarui'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Transaksi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada transaksi',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshFromServer,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  final tx = _transactions[index];

                  // Handle both Map (from API) dan Transaction object (from DB)
                  String id, namaUser, tanggal, totalHarga, status;

                  if (_useLocalData) {
                    // From local database
                    final transaction = tx as Transaction;
                    id = transaction.idTransaksi.toString();
                    namaUser = transaction.namaUser ?? 'Unknown';
                    tanggal = transaction.tglTransaksi?.split('T')[0] ?? '';
                    totalHarga = 'Rp ${transaction.getTotalHarga()}';
                    status = transaction.status ?? 'completed';
                  } else {
                    // From API
                    final transaction = Transaction.fromApi(
                      tx as Map<String, dynamic>,
                    );
                    id = transaction.idTransaksi.toString();
                    namaUser = transaction.namaUser ?? 'Unknown';
                    tanggal = transaction.tglTransaksi ?? '';
                    totalHarga = 'Rp ${transaction.getTotalHarga()}';
                    status = transaction.status ?? 'completed';
                  }

                  // Determine status color
                  Color statusColor = Colors.orange;
                  if (status.toLowerCase() == 'completed' ||
                      status.toLowerCase() == 'success') {
                    statusColor = Colors.green;
                  } else if (status.toLowerCase() == 'failed' ||
                      status.toLowerCase() == 'error') {
                    statusColor = Colors.red;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 0,
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with ID and Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Transaksi #$id',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pembeli: $namaUser',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                  color: statusColor.withOpacity(0.2),
                                  border: Border.all(color: statusColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Total and Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Transaksi',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    totalHarga,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text(
                                    'Tanggal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tanggal,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.end,
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Source indicator
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _useLocalData
                                    ? '📱 Data Lokal'
                                    : '🌐 Data Server',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: const BottomNav(2),
    );
  }
}
