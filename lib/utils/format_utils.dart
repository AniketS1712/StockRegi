abstract class FormatUtils {
  /// Formats a quantity double without trailing `.0` for whole numbers
  /// (e.g. `10.0` -> "10", `10.5` -> "10.5").
  static String formatQuantity(double quantity) {
    if (quantity == quantity.truncateToDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }

  /// Formats a DateTime with zero-padded day and month: DD/MM/YYYY HH:mm
  /// (e.g. "01/09/2026 09:05").
  static String formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/${dt.year} $hour:$minute';
  }
}
