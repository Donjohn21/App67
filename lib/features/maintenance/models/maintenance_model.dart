import '../../../core/utils/parse_utils.dart';

class MaintenanceRecord {
  final int id;
  final int vehiculoId;
  final String tipo;
  final double costo;
  final String? piezas;
  final String fecha;
  final List<String> fotos;

  MaintenanceRecord({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.costo,
    this.piezas,
    required this.fecha,
    this.fotos = const [],
  });

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: ParseUtils.toIntSafe(json['id']),
      vehiculoId: ParseUtils.toIntSafe(
          json['vehiculo_id'] ?? json['vehiculoId']),
      tipo: json['tipo']?.toString() ?? '',
      // API may return numeric values as String ("3500") or num (3500)
      costo: ParseUtils.toDoubleSafe(json['costo']),
      piezas: json['piezas']?.toString(),
      fecha: json['fecha']?.toString() ?? '',
      fotos: (json['fotos'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
