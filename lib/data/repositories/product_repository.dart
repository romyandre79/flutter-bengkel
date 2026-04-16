import 'package:kreatif_otopart/data/database/database_helper.dart';
import 'package:kreatif_otopart/data/models/product.dart';
import 'package:kreatif_otopart/data/models/product_unit.dart';

class ProductRepository {
  final DatabaseHelper _databaseHelper;

  ProductRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  Future<List<Product>> getProducts({ProductType? type, bool activeOnly = true, String? query}) async {
    final db = await _databaseHelper.database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (activeOnly) {
      whereClause = 'is_active = 1';
    }

    if (type != null) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND type = ?';
      } else {
        whereClause = 'type = ?';
      }
      whereArgs.add(type.value);
    }

    if (query != null && query.isNotEmpty) {
      if (whereClause.isNotEmpty) {
        whereClause += ' AND (name LIKE ? OR barcode = ?)';
      } else {
        whereClause = '(name LIKE ? OR barcode = ?)';
      }
      whereArgs.add('%$query%');
      whereArgs.add(query);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );

    final List<Product> products = [];
    for (final map in maps) {
      final product = Product.fromMap(map);
      
      // Fetch units for goods
      if (product.isGoods) {
        final List<Map<String, dynamic>> unitMaps = await db.query(
          'product_units',
          where: 'product_id = ?',
          whereArgs: [product.id],
        );
        final units = unitMaps.map((u) => ProductUnit.fromMap(u)).toList();
        products.add(product.copyWith(units: units));
      } else {
        products.add(product);
      }
    }
    return products;
  }

  Future<Product?> getProductById(int id) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final product = Product.fromMap(maps.first);
      if (product.isGoods) {
        final List<Map<String, dynamic>> unitMaps = await db.query(
          'product_units',
          where: 'product_id = ?',
          whereArgs: [product.id],
        );
        final units = unitMaps.map((u) => ProductUnit.fromMap(u)).toList();
        return product.copyWith(units: units);
      }
      return product;
    }
    return null;
  }

  Future<int> addProduct(Product product) async {
    final db = await _databaseHelper.database;
    return await db.transaction((txn) async {
      final id = await txn.insert('products', product.toMap());
      
      if (product.isGoods) {
        for (final unit in product.units) {
          await txn.insert('product_units', unit.copyWith(productId: id).toMap());
        }
      }
      
      return id;
    });
  }

  Future<int> updateProduct(Product product) async {
    final db = await _databaseHelper.database;
    return await db.transaction((txn) async {
      final count = await txn.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );

      if (product.isGoods) {
        // Simple strategy: delete and re-insert units
        // Better: diffing, but let's keep it simple for now as per plan
        await txn.delete('product_units', where: 'product_id = ?', whereArgs: [product.id]);
        for (final unit in product.units) {
          await txn.insert('product_units', unit.copyWith(productId: product.id).toMap());
        }
      }
      
      return count;
    });
  }

  Future<int> deleteProduct(int id) async {
    final db = await _databaseHelper.database;
    // Soft delete: set is_active to 0
    return await db.update(
      'products',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> hardDeleteProduct(int id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  Future<void> updateStock(int productId, double quantityChange, {int? unitId}) async {
    final db = await _databaseHelper.database;
    
    // If unitId is provided, it's a specific unit deduction
    if (unitId != null) {
      await db.transaction((txn) async {
        await _deductStockRecursive(txn, unitId, quantityChange.abs());
      });
      return;
    }

    // Fallback: update main stock if no specific unit
    await db.rawUpdate(
      'UPDATE products SET stock = stock + ?, updated_at = ? WHERE id = ?',
      [quantityChange, DateTime.now().toIso8601String(), productId],
    );
  }

  Future<void> _deductStockRecursive(dynamic dbOrTxn, int unitId, double quantityToDeduct) async {
    final List<Map<String, dynamic>> maps = await dbOrTxn.query(
      'product_units',
      where: 'id = ?',
      whereArgs: [unitId],
    );

    if (maps.isEmpty) return;
    final unit = ProductUnit.fromMap(maps.first);

    if (unit.stock >= quantityToDeduct) {
      // Sufficient stock in this unit
      await dbOrTxn.rawUpdate(
        'UPDATE product_units SET stock = stock - ? WHERE id = ?',
        [quantityToDeduct, unitId],
      );
    } else {
      // Insufficient stock, try to deduct from parent
      final remainingNeeded = quantityToDeduct - unit.stock;
      
      // First, empty out this unit
      if (unit.stock > 0) {
        await dbOrTxn.rawUpdate(
          'UPDATE product_units SET stock = 0 WHERE id = ?',
          [unitId],
        );
      }

      if (unit.parentUnitId != null) {
        // Need to know how much to deduct from parent
        // E.g. 1 Box = 12 Pcs. If we need 5 Pcs and current is 0, we take 1 Box and get 12 Pcs, then deduct 5.
        // But the recursive logic can be simpler: 
        // 1. Calculate how many parent units needed to cover 'remainingNeeded'
        final parentNeededCount = (remainingNeeded / unit.multiplier).ceil();
        
        // 2. Deduct that count from parent recursively
        await _deductStockRecursive(dbOrTxn, unit.parentUnitId!, parentNeededCount.toDouble());
        
        // 3. Add the 'converted' stock to this unit (parentCount * multiplier - remainingNeeded)
        final leftoverFromParent = (parentNeededCount * unit.multiplier) - remainingNeeded;
        await dbOrTxn.rawUpdate(
          'UPDATE product_units SET stock = stock + ? WHERE id = ?',
          [leftoverFromParent, unitId],
        );
      } else {
        // No parent, just go negative (or handle as error)
        await dbOrTxn.rawUpdate(
          'UPDATE product_units SET stock = stock - ? WHERE id = ?',
          [remainingNeeded, unitId],
        );
      }
    }
  }

  Future<void> convertUnit({
    required int productId,
    required int fromUnitId,
    required int toUnitId,
    required double fromQty,
    required double multiplier,
  }) async {
    final db = await _databaseHelper.database;
    await db.transaction((txn) async {
      // Deduct from source
      await txn.rawUpdate(
        'UPDATE product_units SET stock = stock - ? WHERE id = ?',
        [fromQty, fromUnitId],
      );
      // Add to target
      await txn.rawUpdate(
        'UPDATE product_units SET stock = stock + ? WHERE id = ?',
        [fromQty * multiplier, toUnitId],
      );
      // Log conversion
      await txn.insert('unit_conversions', {
        'product_id': productId,
        'from_unit_id': fromUnitId,
        'to_unit_id': toUnitId,
        'from_qty': fromQty,
        'to_qty': fromQty * multiplier,
        'multiplier': multiplier,
      });
    });
  }

  Future<void> addProducts(List<Product> products) async {
    final db = await _databaseHelper.database;
    final batch = db.batch();

    for (var product in products) {
      batch.insert('products', product.toMap());
    }

    await batch.commit(noResult: true);
  }
}
