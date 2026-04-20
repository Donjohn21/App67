import '../../../core/utils/parse_utils.dart';

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
      id: ParseUtils.toIntSafe(json['id']),
      tipo: json['tipo']?.toString() ?? '',
      // cantidad / monto may arrive as String from the API
      cantidad: ParseUtils.toDoubleSafe(json['cantidad']),
      unidad: json['unidad']?.toString() ?? '',
      monto: ParseUtils.toDoubleSafe(json['monto']),
      fecha: json['fecha']?.toString() ?? '',
    );
  }
}
