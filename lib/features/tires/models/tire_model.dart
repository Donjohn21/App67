class TireInfo {
  final int cantidadRuedas;
  final List<Tire> gomas;

  TireInfo({required this.cantidadRuedas, required this.gomas});

  factory TireInfo.fromJson(Map<String, dynamic> json) {
    return TireInfo(
      cantidadRuedas: json['cantidadRuedas'] ?? 4,
      gomas: (json['gomas'] as List?)
              ?.map((e) => Tire.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Tire {
  final int id;
  final String posicion;
  final String eje;
  final String estado;
  final int totalPinchazos;

  Tire({
    required this.id,
    required this.posicion,
    required this.eje,
    required this.estado,
    required this.totalPinchazos,
  });

  factory Tire.fromJson(Map<String, dynamic> json) {
    return Tire(
      id: json['id'] ?? 0,
      posicion: json['posicion'] ?? '',
      eje: json['eje'] ?? '',
      estado: json['estado'] ?? 'buena',
      totalPinchazos: json['totalPinchazos'] ?? 0,
    );
  }
}
