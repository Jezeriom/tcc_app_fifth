enum MovementType { ENTRADA, SALIDA }

class MovementModel {
  const MovementModel({
    this.idMovimiento,
    required this.idProducto,
    required this.tipo,
    required this.cantidad,
    this.motivo = '',
    required this.fecha,
  });

  final int? idMovimiento;
  final int idProducto;
  final MovementType tipo;
  final int cantidad;
  final String motivo;
  final DateTime fecha;

  Map<String, Object?> toMap() => {
    'idMovimiento': idMovimiento,
    'idProducto': idProducto,
    'tipo': tipo.name,
    'cantidad': cantidad,
    'motivo': motivo,
    'fecha': fecha.toIso8601String(),
  };

  factory MovementModel.fromMap(Map<String, Object?> map) => MovementModel(
    idMovimiento: (map['idMovimiento'] as num?)?.toInt(),
    idProducto: (map['idProducto'] as num).toInt(),
    tipo: MovementType.values.firstWhere(
      (value) => value.name == map['tipo'],
      orElse: () =>
          throw FormatException('Tipo de movimiento inválido: ${map['tipo']}'),
    ),
    cantidad: (map['cantidad'] as num).toInt(),
    motivo: map['motivo'] as String? ?? '',
    fecha: DateTime.parse(map['fecha'] as String),
  );
}
