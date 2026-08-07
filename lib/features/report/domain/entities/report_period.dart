enum ReportPeriod {
  weekly,
  monthly;

  String get label => this == ReportPeriod.weekly ? 'Mingguan' : 'Bulanan';
}
