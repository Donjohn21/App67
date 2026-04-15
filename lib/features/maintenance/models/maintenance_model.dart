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
      id: json['id'] ?? 0,
      vehiculoId: json['vehiculo_id'] ?? json['vehiculoId'] ?? 0,
      tipo: json['tipo'] ?? '',
      costo: (json['costo'] ?? 0).toDouble(),
      piezas: json['piezas'],
      fecha: json['fecha'] ?? '',
      fotos: (json['fotos'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
