import '../../../core/api/api_client.dart';
import '../models/expense_model.dart';

class ExpenseService {
  static Future<List<ExpenseCategory>> getCategories() async {
    final res = await ApiClient.getAuth('/gastos/categorias');
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => ExpenseCategory.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar categorías');
  }

  static Future<List<Expense>> getExpenses(int vehicleId, {int? categoriaId}) async {
    final query = <String, dynamic>{'vehiculo_id': vehicleId};
    if (categoriaId != null) query['categoria_id'] = categoriaId;
    final res = await ApiClient.getAuth('/gastos', query: query);
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => Expense.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar gastos');
  }

  static Future<Expense> createExpense({
    required int vehiculoId,
    required int categoriaId,
    required double monto,
    required String descripcion,
  }) async {
    final res = await ApiClient.postAuth('/gastos', {
      'vehiculo_id': vehiculoId,
      'categoriaId': categoriaId,
      'monto': monto,
      'descripcion': descripcion,
    });
    final data = res.data;
    if (data['success'] == true) return Expense.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al registrar gasto');
  }

  static Future<List<Income>> getIncomes(int vehicleId) async {
    final res = await ApiClient.getAuth('/ingresos', query: {'vehiculo_id': vehicleId});
    final data = res.data;
    if (data['success'] == true) {
      return (data['data'] as List).map((e) => Income.fromJson(e)).toList();
    }
    throw Exception(data['message'] ?? 'Error al cargar ingresos');
  }

  static Future<Income> createIncome({
    required int vehiculoId,
    required double monto,
    required String concepto,
  }) async {
    final res = await ApiClient.postAuth('/ingresos', {
      'vehiculo_id': vehiculoId,
      'monto': monto,
      'concepto': concepto,
    });
    final data = res.data;
    if (data['success'] == true) return Income.fromJson(data['data']);
    throw Exception(data['message'] ?? 'Error al registrar ingreso');
  }
}
