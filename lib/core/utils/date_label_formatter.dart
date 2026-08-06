/// Label tanggal untuk header grup di Transaction List (sesuai Tahap 4):
/// "Hari Ini", "Kemarin", atau tanggal biasa.
class DateLabelFormatter {
  DateLabelFormatter._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return 'Hari Ini';
    if (diff == 1) return 'Kemarin';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }
}
