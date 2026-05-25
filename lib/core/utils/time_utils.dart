class TimeUtils {
  TimeUtils._();
  static int getCurrentWeek(DateTime semesterStart){final diff=DateTime.now().difference(semesterStart);return (diff.inDays/7).ceil().clamp(1,20);}
  static String formatWeekRange(int week,DateTime semesterStart){final s=semesterStart.add(Duration(days:(week-1)*7));final e=s.add(const Duration(days:6));return '${s.month}/${s.day}-${e.month}/${e.day}';}
}
