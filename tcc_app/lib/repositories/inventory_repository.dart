import '../core/database/database_helper.dart';
import '../models/inventory_summary_model.dart';
import '../models/movement_model.dart';
import '../models/product_model.dart';
import 'i_inventory_repository.dart';

class InventoryRepository implements IInventoryRepository {
  InventoryRepository({DatabaseHelper? databaseHelper})
    : _database = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _database;

  @override
  Future<int> createProduct(ProductModel product) =>
      _database.insertProduct(product);

  @override
  Future<ProductModel?> getProduct(int id) => _database.getProduct(id);

  @override
  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoria,
    bool soloBajoStock = false,
  }) => _database.getProducts(
    search: search,
    categoria: categoria,
    soloBajoStock: soloBajoStock,
  );

  @override
  Future<int> updateProduct(ProductModel product) =>
      _database.updateProduct(product);

  @override
  Future<int> deleteProduct(int id) => _database.deleteProduct(id);

  @override
  Future<List<String>> getCategories() => _database.getCategories();

  @override
  Future<Map<String, int>> getCategoryCounts() => _database.getCategoryCounts();

  @override
  Future<int> registerMovement(MovementModel movement) =>
      _database.registerMovement(movement);

  @override
  Future<int> updateMovement(MovementModel movement) =>
      _database.updateMovement(movement);

  @override
  Future<int> deleteMovement(int idMovimiento) =>
      _database.deleteMovement(idMovimiento);

  @override
  Future<List<MovementModel>> getMovements({
    int? idProducto,
    MovementType? tipo,
    DateTime? desde,
    DateTime? hasta,
  }) => _database.getMovements(
    idProducto: idProducto,
    tipo: tipo,
    desde: desde,
    hasta: hasta,
  );

  @override
  Future<InventorySummaryModel> getInventorySummary() =>
      _database.getInventorySummary();
}
