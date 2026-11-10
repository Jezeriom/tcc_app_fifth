import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:tcc_app/core/database/database_helper.dart';
import 'package:tcc_app/models/inventory_summary_model.dart';
import 'package:tcc_app/models/movement_model.dart';
import 'package:tcc_app/models/product_model.dart';

void main() {
  final database = DatabaseHelper.instance;

  setUpAll(() async {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
    await databaseFactoryFfi.setDatabasesPath(
      '${Directory.current.path}${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}test_databases',
    );
  });

  setUp(() async {
    await database.close();
    await databaseFactoryFfi.deleteDatabase(
      '${Directory.current.path}${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}test_databases${Platform.pathSeparator}${DatabaseHelper.databaseName}',
    );
  });

  tearDown(() => database.close());

  test('ProductModel serializes and restores every field', () {
    final product = ProductModel(
      id: 7,
      nombre: 'Teclado',
      descripcion: 'Mecánico',
      categoria: 'Periféricos',
      cantidad: 4,
      precio: 89.5,
      fechaIngreso: DateTime.utc(2026, 10, 20),
      stockMinimo: 2,
      codigoSku: 'TEC-007',
    );

    final restored = ProductModel.fromMap(product.toMap());
    expect(restored.id, 7);
    expect(restored.nombre, 'Teclado');
    expect(restored.descripcion, 'Mecánico');
    expect(restored.categoria, 'Periféricos');
    expect(restored.cantidad, 4);
    expect(restored.precio, 89.5);
    expect(restored.fechaIngreso, product.fechaIngreso);
    expect(restored.stockMinimo, 2);
    expect(restored.codigoSku, 'TEC-007');
    expect(product.copyWith(cantidad: 3).cantidad, 3);
  });

  test('MovementModel round-trips both movement type and optional values', () {
    final movement = MovementModel(
      idMovimiento: 3,
      idProducto: 9,
      tipo: MovementType.SALIDA,
      cantidad: 2,
      motivo: 'Venta',
      fecha: DateTime.utc(2026, 10, 21),
    );

    final restored = MovementModel.fromMap(movement.toMap());
    expect(restored.idMovimiento, 3);
    expect(restored.idProducto, 9);
    expect(restored.tipo, MovementType.SALIDA);
    expect(restored.cantidad, 2);
    expect(restored.motivo, 'Venta');
    expect(restored.fecha, movement.fecha);
    expect(
      () => MovementModel.fromMap({...movement.toMap(), 'tipo': 'INVALIDO'}),
      throwsFormatException,
    );
  });

  test('InventorySummaryModel defaults missing aggregate values to zero', () {
    final summary = InventorySummaryModel.fromMap({});
    expect(summary.totalProductos, 0);
    expect(summary.totalUnidades, 0);
    expect(summary.valorTotal, 0);
    expect(summary.productosBajoStock, 0);
  });

  test('inventory summary calculates count, units, value and critical stock', () async {
    await database.insertProduct(_product('A', amount: 5, price: 10, minimum: 2));
    await database.insertProduct(_product('B', amount: 1, price: 7.5, minimum: 1));

    final summary = await database.getInventorySummary();
    expect(summary.totalProductos, 2);
    expect(summary.totalUnidades, 6);
    expect(summary.valorTotal, 57.5);
    expect(summary.productosBajoStock, 1);
  });

  test('movement transactions update stock and rollback invalid exits', () async {
    final productId = await database.insertProduct(_product('A', amount: 5));
    final entradaId = await database.registerMovement(_movement(
      productId,
      MovementType.ENTRADA,
      3,
    ));
    expect((await database.getProduct(productId))!.cantidad, 8);

    final salidaId = await database.registerMovement(_movement(
      productId,
      MovementType.SALIDA,
      6,
    ));
    expect((await database.getProduct(productId))!.cantidad, 2);

    await expectLater(
      database.registerMovement(_movement(productId, MovementType.SALIDA, 3)),
      throwsStateError,
    );
    expect((await database.getProduct(productId))!.cantidad, 2);
    expect((await database.getMovements()).length, 2);

    await database.updateMovement(MovementModel(
      idMovimiento: salidaId,
      idProducto: productId,
      tipo: MovementType.SALIDA,
      cantidad: 1,
      fecha: DateTime.utc(2026, 10, 22),
    ));
    expect((await database.getProduct(productId))!.cantidad, 7);

    await database.deleteMovement(entradaId);
    expect((await database.getProduct(productId))!.cantidad, 4);
    expect((await database.getMovements()).length, 1);
  });

  test('movement rejects zero quantity and unknown products without writes', () async {
    await expectLater(
      database.registerMovement(_movement(1, MovementType.ENTRADA, 0)),
      throwsArgumentError,
    );
    await expectLater(
      database.registerMovement(_movement(999, MovementType.ENTRADA, 1)),
      throwsStateError,
    );
    expect(await database.getMovements(), isEmpty);
  });
}

ProductModel _product(
  String sku, {
  int amount = 0,
  double price = 10,
  int minimum = 0,
}) => ProductModel(
  nombre: 'Producto $sku',
  categoria: 'General',
  cantidad: amount,
  precio: price,
  fechaIngreso: DateTime.utc(2026, 10, 20),
  stockMinimo: minimum,
  codigoSku: sku,
);

MovementModel _movement(int productId, MovementType type, int amount) =>
    MovementModel(
      idProducto: productId,
      tipo: type,
      cantidad: amount,
      fecha: DateTime.utc(2026, 10, 21),
    );
