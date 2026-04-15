class ExpenseCategory {
  final int id;
  final String nombre;

  ExpenseCategory({required this.id, required this.nombre});

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(id: json['id'] ?? 0, nombre: json['nombre'] ?? '');
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
      id: json['id'] ?? 0,
      categoriaId: json['categoriaId'] ?? json['categoria_id'] ?? 0,
      categoriaNombre: json['categoriaNombre'] ?? json['categoria'] ?? '',
      monto: (json['monto'] ?? 0).toDouble(),
      descripcion: json['descripcion'],
      fecha: json['fecha'] ?? '',
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
      id: json['id'] ?? 0,
      monto: (json['monto'] ?? 0).toDouble(),
      concepto: json['concepto'] ?? '',
      fecha: json['fecha'] ?? '',
    );
  }
}
