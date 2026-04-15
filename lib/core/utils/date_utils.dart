import 'package:intl/intl.dart';

class AppDateUtils {
  static String format(String? dateStr, {String pattern = 'dd/MM/yyyy'}) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat(pattern).format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  static String formatCurrency(num? amount) {
    if (amount == null) return 'RD\$0.00';
    return 'RD\$${NumberFormat('#,##0.00').format(amount)}';
  }

  static String timeAgo(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 30) return format(dateStr);
      if (diff.inDays > 0) return 'Hace ${diff.inDays} días';
      if (diff.inHours > 0) return 'Hace ${diff.inHours} horas';
      if (diff.inMinutes > 0) return 'Hace ${diff.inMinutes} minutos';
      return 'Ahora mismo';
    } catch (_) {
      return dateStr ?? '';
    }
  }
}
