class FuelRecord {
  final int id;
  final String tipo;
  final double cantidad;
  final String unidad;
  final double monto;
  final String fecha;

  FuelRecord({
    required this.id,
    required this.tipo,
    required this.cantidad,
    required this.unidad,
    required this.monto,
    required this.fecha,
  });

  factory FuelRecord.fromJson(Map<String, dynamic> json) {
    return FuelRecord(
      id: json['id'] ?? 0,
      tipo: json['tipo'] ?? '',
      cantidad: (json['cantidad'] ?? 0).toDouble(),
      unidad: json['unidad'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      fecha: json['fecha'] ?? '',
    );
  }
}
