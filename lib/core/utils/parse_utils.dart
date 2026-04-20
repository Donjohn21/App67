/// Safe type-conversion helpers for JSON and form input.
///
/// The API may return numbers as either a numeric type or a String
/// (e.g. `"3500"` instead of `3500`).  Using `.toDouble()` directly on a
/// dynamic value crashes when the runtime type is String.  These helpers
/// handle every combination the API might send.
class ParseUtils {
  ParseUtils._();

  // ── JSON → double ─────────────────────────────────────────────────────────

  /// Converts any JSON value to a [double].
  ///
  /// Handles:
  /// - `null`    → `fallback` (default 0.0)
  /// - `int`     → promoted with `.toDouble()`
  /// - `double`  → returned as-is
  /// - `String`  → parsed with [double.tryParse]; falls back if invalid
  static double toDoubleSafe(dynamic value, {double fallback = 0.0}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    // Any other type (bool, List, Map…) → safe fallback
    return fallback;
  }

  // ── JSON → int ────────────────────────────────────────────────────────────

  /// Converts any JSON value to an [int].
  ///
  /// Handles:
  /// - `null`    → `fallback` (default 0)
  /// - `int`     → returned as-is
  /// - `double`  → truncated with `.toInt()`
  /// - `String`  → parsed with [int.tryParse]; falls back if invalid
  static int toIntSafe(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  // ── Form text → double ────────────────────────────────────────────────────

  /// Parses a user-typed monetary / numeric string.
  ///
  /// Accepts comma or dot as decimal separator.
  /// Returns `null` when the string is not a valid number (use this in
  /// validators to report the error instead of crashing).
  static double? tryParseMontoInput(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final normalized = text.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  /// Same as [tryParseMontoInput] but returns 0.0 on failure.
  /// Use only after the validator has already confirmed the value is valid.
  static double parseMontoInput(String text) =>
      tryParseMontoInput(text) ?? 0.0;
}
