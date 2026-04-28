import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;
import 'package:postman/models/cart.dart';
import 'package:postman/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

class Dbhelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    io.Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'cart.db');
    var db = await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    // ✅ Create cart table
    await db.execute(
      'CREATE TABLE cart('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'product_id INTEGER, '
      'nama_barang TEXT, '
      'harga INTEGER, '
      'image TEXT, '
      'quantity INTEGER)',
    );

    // ✅ Create transactions table
    await db.execute(
      'CREATE TABLE transactions('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'tanggal TEXT, '
      'total_harga INTEGER, '
      'status TEXT, '
      'catatan TEXT)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // ✅ Create transactions table jika belum ada
      try {
        await db.execute(
          'CREATE TABLE transactions('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'tanggal TEXT, '
          'total_harga INTEGER, '
          'status TEXT, '
          'catatan TEXT)',
        );
        print('✅ Transactions table created during upgrade');
      } catch (e) {
        print('⚠️ Transactions table might already exist: $e');
      }
    }
  }

  Future<Cart?> insert(Cart cart) async {
    final dbClient = await database;

    // ✅ Validasi: product_id harus ada dan valid
    if (cart.productId == null || cart.productId! <= 0) {
      print(
        '❌ ERROR: Cannot insert cart with invalid productId. productId: ${cart.productId}',
      );
      return null;
    }

    print(
      '✅ Insert cart - productId: ${cart.productId}, nama: ${cart.namaBarang}, qty: ${cart.quantity}',
    );

    final Map<String, dynamic> map = {
      'product_id': cart.productId,
      'nama_barang': cart.namaBarang ?? 'Produk',
      'harga': cart.harga ?? 0,
      'image': cart.image ?? '',
      'quantity': cart.quantity ?? 1,
    };

    int insertedId = await dbClient.insert(
      'cart',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return Cart(
      id: insertedId,
      productId: cart.productId,
      namaBarang: cart.namaBarang,
      harga: cart.harga,
      image: cart.image,
      quantity: cart.quantity,
    );
  }

  Future<List<Cart>> getCartList() async {
    try {
      final dbClient = await database;
      final List<Map<String, Object?>> queryResult = await dbClient.query(
        'cart',
      );

      print('=== GET CART LIST ===');
      print('Total rows: ${queryResult.length}');

      final List<Cart> cartList = [];

      for (var result in queryResult) {
        print('---');
        print('Raw DB row: $result');

        try {
          final cart = Cart.fromMap(result);
          print('Parsed cart: ${cart.toString()}');
          print('Is valid: ${cart.isValid()}');
          cartList.add(cart);
        } catch (e) {
          print('❌ Error parsing row: $e');
        }
      }

      print('Total valid carts: ${cartList.length}');
      print('====================');

      return cartList;
    } catch (e) {
      print('❌ Error getting cart list: $e');
      return [];
    }
  }

  Future<int> updatequantity(int id, int qty) async {
    final dbClient = await database;
    print('Updating cart ID $id to quantity $qty');
    return await dbClient.update(
      'cart',
      {'quantity': qty},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCart(int id) async {
    final dbClient = await database;
    print('Deleting cart ID $id');
    return await dbClient.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllCart() async {
    final dbClient = await database;
    print('Deleting all cart items');
    return await dbClient.delete('cart');
  }

  // ✅ ================ TRANSACTION METHODS ================

  /// Insert a new transaction to database
  Future<Transaction?> insertTransaction(Transaction transaction) async {
    try {
      final dbClient = await database;

      final totalHarga = transaction.getTotalHarga();
      if (totalHarga <= 0) {
        print(
          '❌ ERROR: Cannot insert transaction with invalid totalHarga. totalHarga: $totalHarga',
        );
        return null;
      }

      print(
        '✅ Insert transaction - idTransaksi: ${transaction.idTransaksi}, namaUser: ${transaction.namaUser}, tgl: ${transaction.tglTransaksi}, total: $totalHarga, status: ${transaction.status}',
      );

      final Map<String, dynamic> map = transaction.toMap();

      int insertedId = await dbClient.insert(
        'transactions',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Transaction(
        idTransaksi: insertedId,
        namaUser: transaction.namaUser,
        tglTransaksi: transaction.tglTransaksi,
        detail: transaction.detail,
        status: transaction.status,
        catatan: transaction.catatan,
      );
    } catch (e) {
      print('❌ Error inserting transaction: $e');
      return null;
    }
  }

  /// Get all transactions from local database
  Future<List<Transaction>> getTransactionList() async {
    try {
      final dbClient = await database;
      final List<Map<String, Object?>> queryResult = await dbClient.query(
        'transactions',
        orderBy: 'id DESC', // ✅ Sort newest first
      );

      print('=== GET TRANSACTION LIST ===');
      print('Total rows: ${queryResult.length}');

      final List<Transaction> transactionList = [];

      for (var result in queryResult) {
        print('---');
        print('Raw DB row: $result');

        try {
          final transaction = Transaction.fromMap(result);
          print('Parsed transaction: ${transaction.toString()}');
          print('Is valid: ${transaction.isValid()}');
          transactionList.add(transaction);
        } catch (e) {
          print('❌ Error parsing row: $e');
        }
      }

      print('Total valid transactions: ${transactionList.length}');
      print('============================');

      return transactionList;
    } catch (e) {
      print('❌ Error getting transaction list: $e');
      return [];
    }
  }

  /// Update transaction status
  Future<int> updateTransactionStatus(int id, String status) async {
    try {
      final dbClient = await database;
      print('Updating transaction ID $id status to $status');
      return await dbClient.update(
        'transactions',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error updating transaction: $e');
      return 0;
    }
  }

  /// Delete a specific transaction
  Future<int> deleteTransaction(int id) async {
    try {
      final dbClient = await database;
      print('Deleting transaction ID $id');
      return await dbClient.delete(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('❌ Error deleting transaction: $e');
      return 0;
    }
  }

  /// Delete all transactions
  Future<int> deleteAllTransactions() async {
    try {
      final dbClient = await database;
      print('Deleting all transactions');
      return await dbClient.delete('transactions');
    } catch (e) {
      print('❌ Error deleting all transactions: $e');
      return 0;
    }
  }

  /// Get transaction by ID
  Future<Transaction?> getTransactionById(int id) async {
    try {
      final dbClient = await database;
      final result = await dbClient.query(
        'transactions',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      return Transaction.fromMap(result.first);
    } catch (e) {
      print('❌ Error getting transaction by ID: $e');
      return null;
    }
  }
}
