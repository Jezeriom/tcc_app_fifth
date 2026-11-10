import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/inventory_summary_model.dart';
import '../models/movement_model.dart';
import '../models/product_model.dart';
import '../repositories/i_inventory_repository.dart';
import '../repositories/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider({IInventoryRepository? repository, bool autoLoad = true})
    : _repository = repository ?? InventoryRepository() {
    if (autoLoad) unawaited(loadInitialData());
  }

  final IInventoryRepository _repository;
  final List<ProductModel> _products = [];
  final List<ProductModel> _criticalProducts = [];
  final List<String> _categories = [];
  final Map<String, int> _categoryCounts = {};
  final List<MovementModel> _movements = [];

  InventorySummaryModel _summary = const InventorySummaryModel(
    totalProductos: 0,
    totalUnidades: 0,
    valorTotal: 0,
    productosBajoStock: 0,
  );
  bool _isLoading = false;
  bool _isMovementLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _lowStockOnly = false;
  int? _movementProductId;
  MovementType? _movementType;
  DateTime? _movementFrom;
  DateTime? _movementTo;
  int _productRequest = 0;
  int _movementRequest = 0;
  Timer? _searchDebounce;
  bool _disposed = false;

  List<ProductModel> get productos => List.unmodifiable(_products);
  List<ProductModel> get productosStockCritico =>
      List.unmodifiable(_criticalProducts);
  List<String> get categorias => List.unmodifiable(_categories);
  Map<String, int> get conteoPorCategoria => Map.unmodifiable(_categoryCounts);
  List<MovementModel> get movimientos => List.unmodifiable(_movements);
  InventorySummaryModel get resumen => _summary;
  bool get isLoading => _isLoading;
  bool get isMovementLoading => _isMovementLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  bool get lowStockOnly => _lowStockOnly;
  MovementType? get movementTypeFilter => _movementType;
  DateTime? get movementDateFrom => _movementFrom;
  DateTime? get movementDateTo => _movementTo;

  Future<void> loadInitialData() async {
    _setLoading(true);
    _clearError();
    try {
      await Future.wait([
        _loadProducts(),
        _loadCriticalProducts(),
        _loadCategories(),
        _loadSummary(),
      ]);
      await loadMovements(
        productId: _movementProductId,
        type: _movementType,
        from: _movementFrom,
        to: _movementTo,
      );
    } catch (error) {
      _setError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadInitialData();

  void setSearchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_refreshProducts());
    });
    _notify();
  }

  Future<void> setCategory(String? category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _notify();
    await _refreshProducts();
  }

  Future<void> setLowStockOnly(bool value) async {
    if (_lowStockOnly == value) return;
    _lowStockOnly = value;
    _notify();
    await _refreshProducts();
  }

  Future<void> clearProductFilters() async {
    _searchDebounce?.cancel();
    _searchQuery = '';
    _selectedCategory = null;
    _lowStockOnly = false;
    _notify();
    await _refreshProducts();
  }

  Future<int?> registerProduct(ProductModel product) async => _mutate(() async {
    final id = await _repository.createProduct(product);
    await _refreshInventory();
    return id;
  });

  Future<bool?> updateProduct(ProductModel product) async => _mutate(() async {
    final changed = await _repository.updateProduct(product);
    await _refreshInventory();
    return changed > 0;
  });

  Future<bool?> deleteProduct(int id) async => _mutate(() async {
    final deleted = await _repository.deleteProduct(id);
    await _refreshInventory();
    await loadMovements(productId: _movementProductId);
    return deleted > 0;
  });

  Future<ProductModel?> getProduct(int id) => _repository.getProduct(id);

  Future<List<MovementModel>> getProductMovements(int productId) =>
      _repository.getMovements(idProducto: productId);

  Future<int?> registerMovement(MovementModel movement) async =>
      _mutate(() async {
        final id = await _repository.registerMovement(movement);
        await _refreshInventory();
        await loadMovements(
          productId: _movementProductId,
          type: _movementType,
          from: _movementFrom,
          to: _movementTo,
        );
        return id;
      });

  Future<bool?> updateMovement(MovementModel movement) async =>
      _mutate(() async {
        final changed = await _repository.updateMovement(movement);
        await _refreshInventory();
        await loadMovements(
          productId: _movementProductId,
          type: _movementType,
          from: _movementFrom,
          to: _movementTo,
        );
        return changed > 0;
      });

  Future<bool?> deleteMovement(int idMovimiento) async => _mutate(() async {
    final deleted = await _repository.deleteMovement(idMovimiento);
    await _refreshInventory();
    await loadMovements(
      productId: _movementProductId,
      type: _movementType,
      from: _movementFrom,
      to: _movementTo,
    );
    return deleted > 0;
  });

  Future<void> loadMovements({
    int? productId,
    MovementType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    _movementProductId = productId;
    _movementType = type;
    _movementFrom = from;
    _movementTo = to;
    final request = ++_movementRequest;
    _isMovementLoading = true;
    _notify();
    try {
      final result = await _repository.getMovements(
        idProducto: productId,
        tipo: type,
        desde: from,
        hasta: to,
      );
      if (request == _movementRequest) {
        _movements
          ..clear()
          ..addAll(result);
      }
    } catch (error) {
      if (request == _movementRequest) _setError(error);
    } finally {
      if (request == _movementRequest) {
        _isMovementLoading = false;
        _notify();
      }
    }
  }

  Future<void> setMovementType(MovementType? type) => loadMovements(
    productId: _movementProductId,
    type: type,
    from: _movementFrom,
    to: _movementTo,
  );

  Future<void> setMovementDateRange(DateTime? from, DateTime? to) =>
      loadMovements(
        productId: _movementProductId,
        type: _movementType,
        from: from,
        to: to,
      );

  Future<void> _refreshProducts() async {
    final request = ++_productRequest;
    _clearError();
    try {
      final result = await _repository.getProducts(
        search: _searchQuery,
        categoria: _selectedCategory,
        soloBajoStock: _lowStockOnly,
      );
      if (request == _productRequest) {
        _products
          ..clear()
          ..addAll(result);
      }
    } catch (error) {
      if (request == _productRequest) _setError(error);
    }
  }

  Future<void> _loadProducts() async {
    final request = ++_productRequest;
    final result = await _repository.getProducts(
      search: _searchQuery,
      categoria: _selectedCategory,
      soloBajoStock: _lowStockOnly,
    );
    if (request == _productRequest) {
      _products
        ..clear()
        ..addAll(result);
      _notify();
    }
  }

  Future<void> _loadCriticalProducts() async {
    final result = await _repository.getProducts(soloBajoStock: true);
    _criticalProducts
      ..clear()
      ..addAll(result);
    _notify();
  }

  Future<void> _loadCategories() async {
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getCategoryCounts(),
    ]);
    final result = results[0] as List<String>;
    final counts = results[1] as Map<String, int>;
    _categories
      ..clear()
      ..addAll(result);
    _categoryCounts
      ..clear()
      ..addAll(counts);
    if (_selectedCategory != null && !_categories.contains(_selectedCategory)) {
      _selectedCategory = null;
    }
    _notify();
  }

  Future<void> _loadSummary() async {
    _summary = await _repository.getInventorySummary();
    _notify();
  }

  Future<void> _refreshInventory() async {
    await Future.wait([
      _refreshProducts(),
      _loadCriticalProducts(),
      _loadCategories(),
      _loadSummary(),
    ]);
  }

  Future<T?> _mutate<T>(Future<T> Function() action) async {
    _clearError();
    try {
      return await action();
    } catch (error) {
      _setError(error);
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _notify();
  }

  void _clearError() {
    _errorMessage = null;
    _notify();
  }

  void _setError(Object error) {
    _errorMessage = error.toString();
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _searchDebounce?.cancel();
    super.dispose();
  }
}
