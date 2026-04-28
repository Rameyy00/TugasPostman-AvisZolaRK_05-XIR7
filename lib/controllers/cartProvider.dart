import 'package:flutter/material.dart';
import 'package:postman/models/cart.dart';
import 'package:postman/services/dbhelper.dart';

class CartProvider extends ChangeNotifier {
  List<Cart> cart = [];
  final Dbhelper _dbhelper = Dbhelper();

  int get counter => cart.length;

  int get totalItems {
    return cart.fold(0, (sum, item) => sum + (item.quantity ?? 0));
  }

  int get totalPrice {
    return cart.fold(0, (sum, item) => sum + item.totalPrice);
  }

  Future<void> fetchCart() async {
    cart = await _dbhelper.getCartList();

    // ✅ DEBUG: Print semua data cart
    print('=== CART DATA ===');
    print('Total cart items: ${cart.length}');
    for (var item in cart) {
      print('---');
      print('Item: ${item.toString()}');
      print('Valid: ${item.isValid()}');
      print(
        'productId: ${item.productId} (type: ${item.productId.runtimeType})',
      );
      print('quantity: ${item.quantity} (type: ${item.quantity.runtimeType})');
    }
    print('=================');

    notifyListeners();
  }

  Future<void> addToCart(Cart newItem) async {
    // ✅ Validasi ketat: product_id harus ada dan valid
    if (newItem.productId == null || newItem.productId! <= 0) {
      print(
        '❌ ERROR: Cannot add cart item with invalid productId: ${newItem.productId}',
      );
      return;
    }

    if (!newItem.isValid()) {
      print('❌ ERROR: Cannot add invalid cart item: ${newItem.toString()}');
      return;
    }

    // ✅ DEBUG: Print item yang akan ditambahkan
    print('Adding to cart: ${newItem.toString()}');

    final existingIndex = cart.indexWhere(
      (item) => item.productId == newItem.productId,
    );

    if (existingIndex != -1) {
      int newQty = (cart[existingIndex].quantity ?? 0) + 1;
      await _dbhelper.updatequantity(cart[existingIndex].id!, newQty);
    } else {
      await _dbhelper.insert(newItem);
    }
    await fetchCart();
  }

  Future<void> addQuantity(int cartId) async {
    final index = cart.indexWhere((item) => item.id == cartId);
    if (index != -1) {
      int newQty = (cart[index].quantity ?? 0) + 1;
      await _dbhelper.updatequantity(cartId, newQty);
      await fetchCart();
    }
  }

  Future<void> deleteQuantity(int cartId) async {
    final index = cart.indexWhere((item) => item.id == cartId);
    if (index != -1) {
      int currentQty = cart[index].quantity ?? 0;
      if (currentQty <= 1) {
        await _dbhelper.deleteCart(cartId);
      } else {
        await _dbhelper.updatequantity(cartId, currentQty - 1);
      }
      await fetchCart();
    }
  }

  Future<void> removeItem(int cartId) async {
    await _dbhelper.deleteCart(cartId);
    await fetchCart();
  }

  Future<void> clearCart() async {
    await _dbhelper.deleteAllCart();
    await fetchCart();
  }

  Future<List<Cart>> getData() async {
    await fetchCart();
    return cart;
  }
}
