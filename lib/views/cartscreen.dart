import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:postman/controllers/cartProvider.dart';
import 'package:postman/services/transaksi.dart';
import 'package:postman/widgets/alert.dart';
import 'package:postman/widgets/tombol_plus_minus.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: _buildAppBar(),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cart.isEmpty) {
            return _buildEmptyCart();
          }
          return Column(
            children: [
              _buildSummaryCard(cartProvider),
              Expanded(child: _buildCartList(cartProvider)),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.cart.isEmpty) return const SizedBox.shrink();
          return _buildCheckoutButton(cartProvider);
        },
      ),
    );
  }

  // ─── AppBar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: false,
      elevation: 0,
      backgroundColor: const Color(0xFF1B5E20),
      foregroundColor: Colors.white,
      title: const Text(
        'Keranjang',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: 0.3,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          ),
        ),
      ),
      actions: [
        Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            return badges.Badge(
              badgeContent: Text(
                '${cartProvider.counter}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              badgeStyle: const badges.BadgeStyle(
                badgeColor: Color(0xFFFF6F00),
                padding: EdgeInsets.all(5),
              ),
              position: badges.BadgePosition.topEnd(top: 0, end: 2),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_rounded),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: Color(0xFF66BB6A),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Keranjang Kosong',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: Color(0xFF2E7D32),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan barang ke keranjang\nuntuk mulai belanja',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Summary Card ──────────────────────────────────────────────────────────

  Widget _buildSummaryCard(CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${cartProvider.totalItems} item dipilih',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatPrice(cartProvider.totalPrice)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Clear button
            GestureDetector(
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: const Text(
                      'Konfirmasi',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    content: const Text('Hapus semua item dari keranjang?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await cartProvider.clearCart();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_sweep_rounded,
                        size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Hapus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Cart List ─────────────────────────────────────────────────────────────

  Widget _buildCartList(CartProvider cartProvider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: cartProvider.cart.length,
      itemBuilder: (context, index) {
        final item = cartProvider.cart[index];
        return _buildCartItem(item, cartProvider);
      },
    );
  }

  Widget _buildCartItem(item, CartProvider cartProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Gambar produk ────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(
                height: 80,
                width: 80,
                image: NetworkImage(item.image ?? ''),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    size: 32,
                    color: Color(0xFF81C784),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Info produk ──────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.namaBarang ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${_formatPrice(item.harga ?? 0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Subtotal badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Subtotal: Rp ${_formatPrice(item.totalPrice)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // DEBUG INFO (tetap ada, hanya diperkecil)
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${item.productId}, Qty: ${item.quantity}, Valid: ${item.isValid()}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFBDBDBD),
                    ),
                  ),
                ],
              ),
            ),

            // ── Kontrol qty + hapus ──────────────────────────────────────
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TombolPlusMinus(
                  addQuantity: () {
                    if (item.id != null) cartProvider.addQuantity(item.id!);
                  },
                  deleteQuantity: () {
                    if (item.id != null) cartProvider.deleteQuantity(item.id!);
                  },
                  text: '${item.quantity ?? 0}',
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    if (item.id != null) {
                      await cartProvider.removeItem(item.id!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFFE53935),
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

  // ─── Checkout Button ───────────────────────────────────────────────────────

  Widget _buildCheckoutButton(CartProvider cartProvider) {
    if (_isLoading) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: const Color(0xFF2E7D32),
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        ),
        label: const Text(
          'Memproses...',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        tooltip: "Checkout",
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        onPressed: () async {
          // ════════════════════════════════════════════════
          // SEMUA LOGIKA CHECKOUT TETAP SAMA — TIDAK DIUBAH
          // ════════════════════════════════════════════════
          print('\n=== CHECKOUT PROCESS START ===');
          print('Total cart items: ${cartProvider.cart.length}');

          if (cartProvider.cart.isEmpty) {
            print('ERROR: Cart is empty');
            AlertMessage().showAlert(context, "Keranjang kosong", false);
            return;
          }

          setState(() => _isLoading = true);

          try {
            print('\n--- Validating items ---');
            for (var i = 0; i < cartProvider.cart.length; i++) {
              var item = cartProvider.cart[i];
              print('Item $i:');
              print(
                  '  productId: ${item.productId} (${item.productId.runtimeType})');
              print(
                  '  quantity: ${item.quantity} (${item.quantity.runtimeType})');
              print('  productId != null: ${item.productId != null}');
              print(
                  '  productId! > 0: ${item.productId != null ? item.productId! > 0 : 'N/A'}');
              print('  quantity != null: ${item.quantity != null}');
              print(
                  '  quantity! > 0: ${item.quantity != null ? item.quantity! > 0 : 'N/A'}');
              print('  isValid(): ${item.isValid()}');
            }

            final validItems = cartProvider.cart.where((i) {
              bool isValid = i.isValid();
              if (!isValid) {
                print('INVALID ITEM FOUND:');
                print('  namaBarang: ${i.namaBarang}');
                print('  quantity: ${i.quantity}');
                print('  harga: ${i.harga}');
                print('  Full item: ${i.toString()}');
              } else {
                print('✅ VALID ITEM: ${i.namaBarang} qty=${i.quantity}');
              }
              return isValid;
            }).toList();

            print('\n--- Validation Result ---');
            print('Total items: ${cartProvider.cart.length}');
            print('Valid items: ${validItems.length}');
            print(
                'Invalid items: ${cartProvider.cart.length - validItems.length}');

            if (validItems.isEmpty) {
              print('ERROR: No valid items found');
              for (var item in cartProvider.cart) {
                print('  ${item.toString()} - isValid: ${item.isValid()}');
              }
              AlertMessage().showAlert(
                context,
                "Tidak ada item valid untuk checkout. Silakan periksa data barang.",
                false,
              );
              setState(() => _isLoading = false);
              return;
            }

            final List<Map<String, dynamic>> dataList = validItems
                .where((i) => i.productId != null && i.productId! > 0)
                .map((i) => {
                      "barang_id": i.productId,
                      "qty": i.quantity,
                    })
                .toList();

            print('\n--- Request Data Validation ---');
            print('Valid items before filter: ${validItems.length}');
            print('Items with valid product_id: ${dataList.length}');

            if (dataList.isEmpty) {
              print('ERROR: No items with valid product_id');
              for (var item in validItems) {
                print(
                    '  Item: ${item.namaBarang}, productId: ${item.productId}');
              }
              AlertMessage().showAlert(
                context,
                "Data produk tidak lengkap. Silakan hapus item dan tambahkan kembali dari daftar barang.",
                false,
              );
              setState(() => _isLoading = false);
              return;
            }

            print('\n--- Request Data Detail ---');
            print('Items to checkout: ${dataList.length}');
            for (int idx = 0; idx < dataList.length; idx++) {
              print('Item $idx: ${dataList[idx]}');
            }
            print('Data list: $dataList');
            print(
                'Request body (pesan): ${json.encode({"pesan": dataList})}');
            print('================================');

            var data = {"pesan": dataList};
            final result = await Pesan().saveToDB(data);

            if (!mounted) return;

            print('\n--- Response ---');
            print('Status: ${result.status}');
            print('Message: ${result.message}');

            if (result.status == true) {
              await cartProvider.clearCart();
              AlertMessage().showAlert(
                context,
                result.message.isNotEmpty
                    ? result.message
                    : "Pembelian berhasil!",
                true,
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/history',
                (Route<dynamic> route) => false,
              );
            } else {
              AlertMessage().showAlert(
                context,
                result.message.isNotEmpty
                    ? result.message
                    : "Pembelian gagal, silakan coba lagi",
                false,
              );
            }
          } catch (e, stackTrace) {
            if (mounted) {
              print('\n=== CHECKOUT ERROR ===');
              print('Error: $e');
              print('StackTrace: $stackTrace');
              AlertMessage().showAlert(
                context,
                "Terjadi kesalahan: ${e.toString()}",
                false,
              );
            }
          } finally {
            if (mounted) setState(() => _isLoading = false);
            print('=== CHECKOUT PROCESS END ===\n');
          }
        },
        icon: const Icon(Icons.shopping_cart_checkout_rounded),
        label: Text(
          'Checkout  •  Rp ${_formatPrice(cartProvider.totalPrice)}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
    );
  }

  // ─── Helper ────────────────────────────────────────────────────────────────

  /// Format angka dengan pemisah ribuan (1000000 → 1.000.000)
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    final n = price is int ? price : int.tryParse(price.toString()) ?? 0;
    return n.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }
}