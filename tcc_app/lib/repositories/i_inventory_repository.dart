import '../models/inventory_summary_model.dart';
import '../models/movement_model.dart';
import '../models/product_model.dart';

abstract interface class IInventoryRepository {
  Future<int> createProduct(ProductModel product);

  Future<ProductModel?> getProduct(int id);

  Future<List<ProductModel>> getProducts({
    String? search,
    String? categoria,
    bool soloBajoStock,
  });

  Future<int> updateProduct(ProductModel product);

  Future<int> deleteProduct(int id);

  Future<List<String>> getCategories();

  Future<Map<String, int>> getCategoryCounts();

  Future<int> registerMovement(MovementModel movement);

  Future<int> updateMovement(MovementModel movement);

  Future<int> deleteMovement(int idMovimiento);

  Future<List<MovementModel>> getMovements({
    int? idProducto,
    MovementType? tipo,
    DateTime? desde,
    DateTime? hasta,
  });

  Future<InventorySummaryModel> getInventorySummary();
}
