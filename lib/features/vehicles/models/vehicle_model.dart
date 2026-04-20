import '../../../core/utils/parse_utils.dart';

class Vehicle {
  final int id;
  final String placa;
  final String chasis;
  final String marca;
  final String modelo;
  final int anio;
  final int cantidadRuedas;
  final String? foto;
  final String? fecha;
  // Financial summary (from detail endpoint)
  final double? totalMantenimientos;
  final double? totalCombustible;
  final double? totalGastos;
  final double? totalIngresos;
  final double? inversion;
  final double? balance;

  Vehicle({
    required this.id,
    required this.placa,
    required this.chasis,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.cantidadRuedas,
    this.foto,
    this.fecha,
    this.totalMantenimientos,
    this.totalCombustible,
    this.totalGastos,
    this.totalIngresos,
    this.inversion,
    this.balance,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final fin = json['resumenFinanciero'] as Map<String, dynamic>?;
    return Vehicle(
      id: ParseUtils.toIntSafe(json['id']),
      placa: json['placa']?.toString() ?? '',
      chasis: json['chasis']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      modelo: json['modelo']?.toString() ?? '',
      // anio / cantidadRuedas may arrive as String
      anio: ParseUtils.toIntSafe(json['anio']),
      cantidadRuedas: ParseUtils.toIntSafe(json['cantidadRuedas'],
          fallback: 4),
      foto: json['foto']?.toString(),
      fecha: json['fecha']?.toString(),
      // Financial fields may be String, int, double, or absent
      totalMantenimientos:
          fin != null ? ParseUtils.toDoubleSafe(fin['totalMantenimientos']) : null,
      totalCombustible:
          fin != null ? ParseUtils.toDoubleSafe(fin['totalCombustible']) : null,
      totalGastos:
          fin != null ? ParseUtils.toDoubleSafe(fin['totalGastos']) : null,
      totalIngresos:
          fin != null ? ParseUtils.toDoubleSafe(fin['totalIngresos']) : null,
      inversion:
          fin != null ? ParseUtils.toDoubleSafe(fin['inversion']) : null,
      balance:
          fin != null ? ParseUtils.toDoubleSafe(fin['balance']) : null,
    );
  }

  String get fullName => '$marca $modelo $anio';
}
