class ProductModel {
  const ProductModel({
    this.id,
    required this.nombre,
    this.descripcion = '',
    required this.categoria,
    required this.cantidad,
    required this.precio,
    required this.fechaIngreso,
    required this.stockMinimo,
    required this.codigoSku,
  });

  final int? id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final int cantidad;
  final double precio;
  final DateTime fechaIngreso;
  final int stockMinimo;
  final String codigoSku;

  Map<String, Object?> toMap() => {
    'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'categoria': categoria,
    'cantidad': cantidad,
    'precio': precio,
    'fechaIngreso': fechaIngreso.toIso8601String(),
    'stockMinimo': stockMinimo,
    'codigoSku': codigoSku,
  };

  factory ProductModel.fromMap(Map<String, Object?> map) => ProductModel(
    id: (map['id'] as num?)?.toInt(),
    nombre: map['nombre'] as String,
    descripcion: map['descripcion'] as String? ?? '',
    categoria: map['categoria'] as String,
    cantidad: (map['cantidad'] as num).toInt(),
    precio: (map['precio'] as num).toDouble(),
    fechaIngreso: DateTime.parse(map['fechaIngreso'] as String),
    stockMinimo: (map['stockMinimo'] as num).toInt(),
    codigoSku: map['codigoSku'] as String,
  );

  ProductModel copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    String? categoria,
    int? cantidad,
    double? precio,
    DateTime? fechaIngreso,
    int? stockMinimo,
    String? codigoSku,
  }) => ProductModel(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    categoria: categoria ?? this.categoria,
    cantidad: cantidad ?? this.cantidad,
    precio: precio ?? this.precio,
    fechaIngreso: fechaIngreso ?? this.fechaIngreso,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    codigoSku: codigoSku ?? this.codigoSku,
  );
}
