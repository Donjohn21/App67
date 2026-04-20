import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../services/expense_service.dart';
import '../../../core/widgets/app_widgets.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/parse_utils.dart';
import '../../../core/theme/app_theme.dart';

class ExpensesScreen extends StatefulWidget {
  final int vehicleId;
  const ExpensesScreen({super.key, required this.vehicleId});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Expense>? _expenses;
  List<Income>? _incomes;
  List<ExpenseCategory>? _categories;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _error = null; _expenses = null; _incomes = null; });
    try {
      final cats = await ExpenseService.getCategories();
      final exp = await ExpenseService.getExpenses(widget.vehicleId);
      final inc = await ExpenseService.getIncomes(widget.vehicleId);
      if (mounted) setState(() { _categories = cats; _expenses = exp; _incomes = inc; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _showAddExpense() async {
    if (_categories == null || _categories!.isEmpty) return;
    final formKey = GlobalKey<FormState>();
    final montoCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int catId = _categories![0].id;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar Gasto'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(builder: (ctx, setS) => DropdownButtonFormField<int>(
                value: catId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categories!.map((c) => DropdownMenuItem(
                  value: c.id, child: Text(c.nombre))).toList(),
                onChanged: (v) => setS(() => catId = v ?? catId),
              )),
              const SizedBox(height: 12),
              TextFormField(
                controller: montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                  if (ParseUtils.tryParseMontoInput(v) == null) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await ExpenseService.createExpense(
                  vehiculoId: widget.vehicleId,
                  categoriaId: catId,
                  // Validator already confirmed this is a valid number
                  monto: ParseUtils.parseMontoInput(montoCtrl.text),
                  descripcion: descCtrl.text.trim(),
                );
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.error));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddIncome() async {
    final formKey = GlobalKey<FormState>();
    final montoCtrl = TextEditingController();
    final conceptoCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Registrar Ingreso'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto (RD\$)'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                  if (ParseUtils.tryParseMontoInput(v) == null) {
                    return 'Ingresa un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: conceptoCtrl,
                decoration: const InputDecoration(labelText: 'Concepto'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Campo requerido' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await ExpenseService.createIncome(
                  vehiculoId: widget.vehicleId,
                  monto: ParseUtils.parseMontoInput(montoCtrl.text),
                  concepto: conceptoCtrl.text.trim(),
                );
                _load();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppTheme.error));
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gastos & Ingresos'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(icon: Icon(Icons.trending_down), text: 'Gastos'),
            Tab(icon: Icon(Icons.trending_up), text: 'Ingresos'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _tab.index == 0 ? _showAddExpense() : _showAddIncome(),
        child: const Icon(Icons.add),
      ),
      body: _error != null
          ? AppError(message: _error!, onRetry: _load)
          : TabBarView(
              controller: _tab,
              children: [
                _ExpenseList(expenses: _expenses),
                _IncomeList(incomes: _incomes),
              ],
            ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  final List<Expense>? expenses;
  const _ExpenseList({required this.expenses});

  @override
  Widget build(BuildContext context) {
    if (expenses == null) return const AppLoading();
    if (expenses!.isEmpty) return const AppEmpty(message: 'No hay gastos registrados', icon: Icons.trending_down);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses!.length,
      itemBuilder: (_, i) {
        final e = expenses![i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.receipt_outlined, color: AppTheme.error),
            ),
            title: Text(e.categoriaNombre, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.descripcion != null) Text(e.descripcion!, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(AppDateUtils.format(e.fecha), style: const TextStyle(fontSize: 11)),
              ],
            ),
            trailing: Text(AppDateUtils.formatCurrency(e.monto),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.error)),
          ),
        );
      },
    );
  }
}

class _IncomeList extends StatelessWidget {
  final List<Income>? incomes;
  const _IncomeList({required this.incomes});

  @override
  Widget build(BuildContext context) {
    if (incomes == null) return const AppLoading();
    if (incomes!.isEmpty) return const AppEmpty(message: 'No hay ingresos registrados', icon: Icons.trending_up);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: incomes!.length,
      itemBuilder: (_, i) {
        final inc = incomes![i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.attach_money, color: AppTheme.success),
            ),
            title: Text(inc.concepto, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(AppDateUtils.format(inc.fecha), style: const TextStyle(fontSize: 11)),
            trailing: Text(AppDateUtils.formatCurrency(inc.monto),
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
          ),
        );
      },
    );
  }
}
