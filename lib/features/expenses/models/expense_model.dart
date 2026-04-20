import '../../../core/utils/parse_utils.dart';

class ExpenseCategory {
  final int id;
  final String nombre;

  ExpenseCategory({required this.id, required this.nombre});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: ParseUtils.toIntSafe(json['id']),
      nombre: json['nombre']?.toString() ?? '',
    );
  }
}

class Expense {
  final int id;
  final int categoriaId;
  final String categoriaNombre;
  final double monto;
  final String? descripcion;
  final String fecha;

  Expense({
    required this.id,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.monto,
    this.descripcion,
    required this.fecha,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: ParseUtils.toIntSafe(json['id']),
      categoriaId: ParseUtils.toIntSafe(
          json['categoriaId'] ?? json['categoria_id']),
      categoriaNombre:
          json['categoriaNombre']?.toString() ??
          json['categoria']?.toString() ??
          '',
      // monto may arrive as String from the API
      monto: ParseUtils.toDoubleSafe(json['monto']),
      descripcion: json['descripcion']?.toString(),
      fecha: json['fecha']?.toString() ?? '',
    );
  }
}

class Income {
  final int id;
  final double monto;
  final String concepto;
  final String fecha;

  Income({
    required this.id,
    required this.monto,
    required this.concepto,
    required this.fecha,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: ParseUtils.toIntSafe(json['id']),
      // monto may arrive as String from the API
      monto: ParseUtils.toDoubleSafe(json['monto']),
      concepto: json['concepto']?.toString() ?? '',
      fecha: json['fecha']?.toString() ?? '',
    );
  }
}
