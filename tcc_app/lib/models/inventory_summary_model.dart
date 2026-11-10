class InventorySummaryModel {
  const InventorySummaryModel({
    required this.totalProductos,
    required this.totalUnidades,
    required this.valorTotal,
    required this.productosBajoStock,
  });

  final int totalProductos;
  final int totalUnidades;
  final double valorTotal;
  final int productosBajoStock;

  factory InventorySummaryModel.fromMap(Map<String, Object?> map) =>
      InventorySummaryModel(
        totalProductos: (map['totalProductos'] as num?)?.toInt() ?? 0,
        totalUnidades: (map['totalUnidades'] as num?)?.toInt() ?? 0,
        valorTotal: (map['valorTotal'] as num?)?.toDouble() ?? 0,
        productosBajoStock: (map['productosBajoStock'] as num?)?.toInt() ?? 0,
      );
}
