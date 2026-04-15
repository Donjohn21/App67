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
      id: json['id'] ?? 0,
      placa: json['placa'] ?? '',
      chasis: json['chasis'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: json['anio'] ?? 0,
      cantidadRuedas: json['cantidadRuedas'] ?? 4,
      foto: json['foto'],
      fecha: json['fecha'],
      totalMantenimientos: (fin?['totalMantenimientos'] ?? 0).toDouble(),
      totalCombustible: (fin?['totalCombustible'] ?? 0).toDouble(),
      totalGastos: (fin?['totalGastos'] ?? 0).toDouble(),
      totalIngresos: (fin?['totalIngresos'] ?? 0).toDouble(),
      inversion: (fin?['inversion'] ?? 0).toDouble(),
      balance: (fin?['balance'] ?? 0).toDouble(),
    );
  }

  String get fullName => '$marca $modelo $anio';
}
