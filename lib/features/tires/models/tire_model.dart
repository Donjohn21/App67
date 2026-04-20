import '../../../core/utils/parse_utils.dart';

class TireInfo {
  final int cantidadRuedas;
  final List<Tire> gomas;

  TireInfo({required this.cantidadRuedas, required this.gomas});

  factory TireInfo.fromJson(Map<String, dynamic> json) {
    return TireInfo(
      // cantidadRuedas may come as String ("4") instead of int
      cantidadRuedas: ParseUtils.toIntSafe(json['cantidadRuedas'],
          fallback: 4),
      gomas: (json['gomas'] as List?)
              ?.map((e) => Tire.fromJson(e as Map<String, dynamic>))
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
      // id / totalPinchazos may come as String ("1") instead of int
      id: ParseUtils.toIntSafe(json['id']),
      posicion: json['posicion']?.toString() ?? '',
      eje: json['eje']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'buena',
      totalPinchazos: ParseUtils.toIntSafe(json['totalPinchazos']),
    );
  }
}
