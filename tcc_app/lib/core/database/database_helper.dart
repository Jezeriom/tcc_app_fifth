import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../models/inventory_summary_model.dart';
import '../../models/movement_model.dart';
import '../../models/product_model.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static const String databaseName = 'inventario_tcc.db';
  static const int databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final directory = await getDatabasesPath();
    return openDatabase(
      p.join(directory, databaseName),
      version: databaseVersion,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        descripcion TEXT NOT NULL DEFAULT '',
        categoria TEXT NOT NULL,
        cantidad INTEGER NOT NULL CHECK (cantidad >= 0),
        precio REAL NOT NULL CHECK (precio >= 0),
        fechaIngreso TEXT NOT NULL,
        stockMinimo INTEGER NOT NULL DEFAULT 0 CHECK (stockMinimo >= 0),
        codigoSku TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE movimientos (
        idMovimiento INTEGER PRIMARY KEY AUTOINCREMENT,
        idProducto INTEGER NOT NULL,
        tipo TEXT NOT NULL CHECK (tipo IN ('ENTRADA', 'SALIDA')),
        cantidad INTEGER NOT NULL CHECK (cantidad > 0),
        motivo TEXT NOT NULL DEFAULT '',
        fecha TEXT NOT NULL,
        FOREIGN KEY (idProducto) REFERENCES productos(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_productos_nombre ON productos(nombre COLLATE NOCASE)',
    );
    await db.execute(
      'CREATE INDEX idx_productos_categoria ON productos(categoria COLLATE NOCASE)',
    );
    await db.execute(
      'CREATE INDEX idx_productos_stock ON productos(cantidad, stockMinimo)',
    );
    await db.execute(
      'CREATE INDEX idx_movimientos_producto_fecha '
      'ON movimientos(idProducto, fecha DESC)',
    );
    await db.execute(
      'CREATE INDEX idx_movimientos_tipo_fecha '
      'ON movimientos(tipo, fecha DESC)',
    );
  }

  Future<int> insertProduct(ProductModel product) async {
    final db = await database;
    final values = product.toMap()..remove('id');
    return db.insert(
      'productos',
      values,
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<ProductModel?> getProduct(int id) async {
    final db = await database;
    final rows = await db.query(
      'productos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ProductModel.fromMap(rows.first);
  }

  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoria,
    bool soloBajoStock = false,
    String ordenarPor = 'nombre COLLATE NOCASE',
  }) async {
    const allowedOrder = {
      'nombre COLLATE NOCASE',
      'categoria COLLATE NOCASE',
      'cantidad',
      'precio',
      'fechaIngreso',
    };
    if (!allowedOrder.contains(ordenarPor)) {
      throw ArgumentError.value(ordenarPor, 'ordenarPor', 'Orden no permitido');
    }

    final clauses = <String>[];
    final args = <Object?>[];
    final normalizedSearch = search?.trim();
    if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
      clauses.add('(nombre LIKE ? OR codigoSku LIKE ? OR descripcion LIKE ?)');
      final pattern = '%$normalizedSearch%';
      args.addAll([pattern, pattern, pattern]);
    }
    if (categoria != null && categoria.trim().isNotEmpty) {
      clauses.add('categoria = ? COLLATE NOCASE');
      args.add(categoria.trim());
    }
    if (soloBajoStock) clauses.add('cantidad <= stockMinimo');

    final rows = await (await database).query(
      'productos',
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: ordenarPor,
    );
    return rows.map(ProductModel.fromMap).toList(growable: false);
  }

  Future<int> updateProduct(ProductModel product) async {
    final id = product.id;
    if (id == null) {
      throw ArgumentError('El producto debe tener id para actualizarse');
    }
    final values = product.toMap()..remove('id');
    return (await database).update(
      'productos',
      values,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<int> deleteProduct(int id) async =>
      (await database).delete('productos', where: 'id = ?', whereArgs: [id]);

  Future<List<String>> getCategories() async {
    final rows = await (await database).rawQuery(
      'SELECT DISTINCT categoria FROM productos ORDER BY categoria COLLATE NOCASE',
    );
    return rows
        .map((row) => row['categoria']! as String)
        .toList(growable: false);
  }

  Future<Map<String, int>> getCategoryCounts() async {
    final rows = await (await database).rawQuery('''
      SELECT categoria, COUNT(*) AS total
      FROM productos
      GROUP BY categoria COLLATE NOCASE
      ORDER BY categoria COLLATE NOCASE
    ''');
    return {
      for (final row in rows) row['categoria']! as String: row['total']! as int,
    };
  }

  Future<InventorySummaryModel> getInventorySummary() async {
    final rows = await (await database).rawQuery('''
      SELECT COUNT(*) AS totalProductos,
             COALESCE(SUM(cantidad), 0) AS totalUnidades,
             COALESCE(SUM(cantidad * precio), 0) AS valorTotal,
             COALESCE(SUM(CASE WHEN cantidad <= stockMinimo THEN 1 ELSE 0 END), 0)
               AS productosBajoStock
      FROM productos
    ''');
    return InventorySummaryModel.fromMap(rows.single);
  }

  Future<int> registerMovement(MovementModel movement) async {
    _validateMovement(movement);
    final db = await database;
    return db.transaction((txn) async {
      await _applyStockChange(txn, movement, 1);
      final values = movement.toMap()..remove('idMovimiento');
      return txn.insert('movimientos', values);
    });
  }

  Future<MovementModel?> getMovement(int idMovimiento) async {
    final rows = await (await database).query(
      'movimientos',
      where: 'idMovimiento = ?',
      whereArgs: [idMovimiento],
      limit: 1,
    );
    return rows.isEmpty ? null : MovementModel.fromMap(rows.first);
  }

  Future<List<MovementModel>> getMovements({
    int? idProducto,
    MovementType? tipo,
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final clauses = <String>[];
    final args = <Object?>[];
    if (idProducto != null) {
      clauses.add('idProducto = ?');
      args.add(idProducto);
    }
    if (tipo != null) {
      clauses.add('tipo = ?');
      args.add(tipo.name);
    }
    if (desde != null) {
      clauses.add('fecha >= ?');
      args.add(desde.toIso8601String());
    }
    if (hasta != null) {
      clauses.add('fecha <= ?');
      args.add(hasta.toIso8601String());
    }
    final rows = await (await database).query(
      'movimientos',
      where: clauses.isEmpty ? null : clauses.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha DESC, idMovimiento DESC',
    );
    return rows.map(MovementModel.fromMap).toList(growable: false);
  }

  Future<int> updateMovement(MovementModel movement) async {
    _validateMovement(movement);
    final id = movement.idMovimiento;
    if (id == null) {
      throw ArgumentError('El movimiento debe tener id para actualizarse');
    }
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'movimientos',
        where: 'idMovimiento = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return 0;

      final previous = MovementModel.fromMap(rows.first);
      await _applyStockChange(txn, previous, -1);
      await _applyStockChange(txn, movement, 1);
      final values = movement.toMap()..remove('idMovimiento');
      return txn.update(
        'movimientos',
        values,
        where: 'idMovimiento = ?',
        whereArgs: [id],
      );
    });
  }

  Future<int> deleteMovement(int idMovimiento) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.query(
        'movimientos',
        where: 'idMovimiento = ?',
        whereArgs: [idMovimiento],
        limit: 1,
      );
      if (rows.isEmpty) return 0;
      await _applyStockChange(txn, MovementModel.fromMap(rows.first), -1);
      return txn.delete(
        'movimientos',
        where: 'idMovimiento = ?',
        whereArgs: [idMovimiento],
      );
    });
  }

  Future<void> _applyStockChange(
    DatabaseExecutor executor,
    MovementModel movement,
    int direction,
  ) async {
    final delta = movement.tipo == MovementType.ENTRADA
        ? movement.cantidad * direction
        : -movement.cantidad * direction;
    final result = await executor.rawUpdate(
      'UPDATE productos SET cantidad = cantidad + ? '
      'WHERE id = ? AND cantidad + ? >= 0',
      [delta, movement.idProducto, delta],
    );
    if (result == 0) {
      final product = await executor.query(
        'productos',
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [movement.idProducto],
        limit: 1,
      );
      if (product.isEmpty) {
        throw StateError('No existe el producto ${movement.idProducto}');
      }
      throw StateError('Stock insuficiente para registrar la salida');
    }
  }

  void _validateMovement(MovementModel movement) {
    if (movement.cantidad <= 0) {
      throw ArgumentError.value(
        movement.cantidad,
        'cantidad',
        'Debe ser mayor que cero',
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    _database = null;
    if (db != null && db.isOpen) await db.close();
  }
}
