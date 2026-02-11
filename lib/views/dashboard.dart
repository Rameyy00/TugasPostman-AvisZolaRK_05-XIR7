import 'package:flutter/material.dart';
import 'package:postman/models/user_login.dart';
import 'package:postman/widgets/bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  UserLogin userLogin = UserLogin();
  String? nama_user;
  String? role;
  int _selectedMenu = 0;


  Map<String, dynamic> stats = {
    'total_pesanan': 124,
    'pendapatan_bulanan': 12500000, 
    'pelanggan_baru': 24,
    'rating': 4.5,
  };


  List<Map<String, dynamic>> pesananTerbaru = [
    {
      'id': 1,
      'nama': 'Semen Tiga Roda',
      'jumlah': 50,
      'status': 'Selesai',
      'tanggal': '2024-03-10',
      'total': 3250000,
    },
    {
      'id': 2,
      'nama': 'Cat Dulux',
      'jumlah': 20,
      'status': 'Proses',
      'tanggal': '2024-03-11',
      'total': 3700000,
    },
    {
      'id': 3,
      'nama': 'Paku Beton',
      'jumlah': 100,
      'status': 'Pending',
      'tanggal': '2024-03-11',
      'total': 2500000,
    },
    {
      'id': 4,
      'nama': 'Keramik 40x40',
      'jumlah': 150,
      'status': 'Selesai',
      'tanggal': '2024-03-09',
      'total': 6750000,
    },
  ];


  List<Map<String, dynamic>> grafikPendapatan = [
    {'bulan': 'Jan', 'pendapatan': 8000000},
    {'bulan': 'Feb', 'pendapatan': 9500000},
    {'bulan': 'Mar', 'pendapatan': 12500000},
    {'bulan': 'Apr', 'pendapatan': 0},
    {'bulan': 'Mei', 'pendapatan': 0},
    {'bulan': 'Jun', 'pendapatan': 0},
  ];

  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.inventory,
      'label': 'Kelola Barang',
      'color': Colors.blue,
      'route': '/kelola',
    },
    {
      'icon': Icons.shopping_cart,
      'label': 'Pesanan',
      'color': Colors.green,
      'route': '/pesanan',
    },
    {
      'icon': Icons.people,
      'label': 'Pelanggan',
      'color': Colors.orange,
      'route': '/pelanggan',
    },
    {
      'icon': Icons.bar_chart,
      'label': 'Laporan',
      'color': Colors.purple,
      'route': '/laporan',
    },
    {
      'icon': Icons.attach_money,
      'label': 'Kas',
      'color': Colors.teal,
      'route': '/kas',
    },
    {
      'icon': Icons.notifications,
      'label': 'Notifikasi',
      'color': Colors.red,
      'route': '/notifikasi',
    },
    {
      'icon': Icons.settings,
      'label': 'Pengaturan',
      'color': Colors.grey,
      'route': '/pengaturan',
    },
    {
      'icon': Icons.help,
      'label': 'Bantuan',
      'color': Colors.brown,
      'route': '/bantuan',
    },
  ];


  String _safeFormatCurrency(NumberFormat format, dynamic value) {
    try {
      double safeValue = 0.0;

      if (value == null) {
        safeValue = 0.0;
      } else if (value is int) {
        safeValue = value.toDouble();
      } else if (value is double) {
        safeValue = value;
      } else if (value is String) {
        safeValue = double.tryParse(value) ?? 0.0;
      }

      // Pastikan nilai tidak negatif
      if (safeValue.isNegative || safeValue.isNaN || safeValue.isInfinite) {
        safeValue = 0.0;
      }

      return format.format(safeValue);
    } catch (e) {
      return 'Rp 0';
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLogin();
  }

  Future<void> _getUserLogin() async {
    UserLogin user = await userLogin.getUserLogin();

    if (!mounted) return;

    if (user.status == true) {
      setState(() {
        nama_user = user.nama_user;
        role = user.role;
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final currentDate = dateFormat.format(DateTime.now());


    final bottomNavHeight = 60.0;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.green.shade800,
                          Colors.green.shade600,
                          Colors.green.shade400,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Selamat datang,",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    nama_user ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(
                                  nama_user?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Role: ${role ?? 'User'}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () async {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: bottomNavHeight + bottomPadding + 20, // Tambahkan padding untuk bottom nav
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Statistik Hari Ini'),
                            const SizedBox(height: 10),

                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2,
                              children: [
                                _buildStatCard(
                                  Icons.shopping_cart,
                                  'Total Pesanan',
                                  stats['total_pesanan'].toString(),
                                  Colors.blue,
                                  '+12% dari bulan lalu',
                                ),
                                _buildStatCard(
                                  Icons.attach_money,
                                  'Pendapatan',
                                  _safeFormatCurrency(
                                    currencyFormat,
                                    stats['pendapatan_bulanan'],
                                  ),
                                  Colors.green,
                                  '+25% dari bulan lalu',
                                ),
                                _buildStatCard(
                                  Icons.people,
                                  'Pelanggan Baru',
                                  stats['pelanggan_baru'].toString(),
                                  Colors.orange,
                                  '+8% dari bulan lalu',
                                ),
                                _buildStatCard(
                                  Icons.star,
                                  'Rating Toko',
                                  stats['rating'].toString(),
                                  Colors.purple,
                                  'Dari 120 ulasan',
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle('Grafik Pendapatan'),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Pendapatan 6 Bulan Terakhir',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          '▲ ${_safeFormatCurrency(currencyFormat, 12500000)}',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 150,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: grafikPendapatan.map((data) {
                                        double pendapatan = (data['pendapatan'] ?? 0)
                                            .toDouble();
                                        double percentage = pendapatan > 0
                                            ? pendapatan / 15000000
                                            : 0.05;

                                        return Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              _safeFormatCurrency(
                                                currencyFormat,
                                                data['pendapatan'],
                                              ),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              width: 30,
                                              height: percentage * 100,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.green.shade400,
                                                    Colors.green.shade600,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              data['bulan'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle('Pesanan Terbaru'),
                            const SizedBox(height: 10),

                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '5 Pesanan Terakhir',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pushNamed(context, '/pesan');
                                          },
                                          child: const Text('Lihat Semua'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...pesananTerbaru
                                      .map(
                                        (pesanan) =>
                                            _buildPesananItem(pesanan, currencyFormat),
                                      )
                                      .toList(),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle('Target Penjualan'),
                            const SizedBox(height: 10),

                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 10,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Target Bulan Maret',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  LinearPercentIndicator(
                                    animation: true,
                                    lineHeight: 20,
                                    animationDuration: 2000,
                                    percent: 0.75,
                                    center: const Text("75%"),
                                    progressColor: Colors.green,
                                    backgroundColor: Colors.grey.shade200,
                                    barRadius: const Radius.circular(10),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tercapai: ${_safeFormatCurrency(currencyFormat, 12500000)}',
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Target: ${_safeFormatCurrency(currencyFormat, 20000000)}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle('Menu Utama'),
                            const SizedBox(height: 10),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.9,
                                  ),
                              itemCount: menuItems.length,
                              itemBuilder: (context, index) {
                                final menu = menuItems[index];
                                return _buildMenuButton(menu, index);
                              },
                            ),

                            const SizedBox(height: 20),

                            _buildSectionTitle('Aksi Cepat'),
                            const SizedBox(height: 10),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickActionButton(
                                    Icons.add,
                                    'Tambah Barang',
                                    Colors.green,
                                    () {
                                      Navigator.pushNamed(context, '/kelola');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    Icons.print,
                                    'Cetak Laporan',
                                    Colors.blue,
                                    () {
                                     
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildQuickActionButton(
                                    Icons.notifications,
                                    'Notifikasi',
                                    Colors.orange,
                                    () {
                                      
                                    },
                                  ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(0),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
    String subtitle,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '+25%',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPesananItem(
    Map<String, dynamic> pesanan,
    NumberFormat currencyFormat,
  ) {
    Color statusColor;
    switch (pesanan['status']) {
      case 'Selesai':
        statusColor = Colors.green;
        break;
      case 'Proses':
        statusColor = Colors.orange;
        break;
      case 'Pending':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(Icons.shopping_bag, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pesanan['nama'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pesanan['jumlah']} item • ${pesanan['tanggal']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _safeFormatCurrency(currencyFormat, pesanan['total']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  pesanan['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(Map<String, dynamic> menu, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMenu = index;
        });
        if (menu['route'] != null) {
          Navigator.pushNamed(context, menu['route']);
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedMenu == index
                  ? menu['color'].withOpacity(0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _selectedMenu == index
                    ? menu['color'].withOpacity(0.3)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(menu['icon'], color: menu['color'], size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            menu['label'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}