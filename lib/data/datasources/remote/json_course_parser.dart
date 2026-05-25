import 'dart:convert';
import '../../models/course.dart';
import '../../models/import_result.dart';
import '../../../core/utils/color_utils.dart';

class JsonCourseParser {
  int _ci = 0;

  ImportResult parseJson(String jsonStr) {
    _ci = 0;
    try {
      final data = jsonDecode(jsonStr);
      final courses = <Course>[];

      if (data is List) {
        for (final item in data) {
          final c = _parseItem(item);
          if (c != null) courses.add(c);
        }
      } else if (data is Map) {
        // Try common wrappers: {data: [...], rows: [...], list: [...]}
        for (final key in ['data', 'rows', 'list', 'result', 'courses', 'lessons', 'schedule', 'kbList', 'kbxx']) {
          final inner = data[key];
          if (inner is List) {
            for (final item in inner) {
              final c = _parseItem(item);
              if (c != null) courses.add(c);
            }
          }
        }
        // Also try the map itself as a single course
        if (courses.isEmpty) {
          final c = _parseItem(data);
          if (c != null) courses.add(c);
        }
      }

      if (courses.isEmpty) return ImportResult.failure('No courses found in JSON response');
      return ImportResult.success(courses);
    } catch (e) {
      return ImportResult.failure('JSON parse error: $e');
    }
  }

  Course? _parseItem(dynamic item) {
    if (item is! Map) return null;
    final m = Map<String, dynamic>.from(item);

    // Try to find course name
    final name = _findField(m, ['courseName', 'kcmc', 'name', 'title', 'className', 'kcm', 'coursename', 'lessonName']);
    if (name == null || name.isEmpty) return null;
    if (name.length > 50) return null;

    final teacher = _findField(m, ['teacher', 'teacherName', 'jsxm', 'jsm', 'instructor', 'skjs', 'rkjs']);
    final location = _findField(m, ['location', 'classroom', 'jsmc', 'place', 'room', 'address', 'skdd', 'jxl']);
    final dayOfWeek = _findDayOfWeek(m);
    final sections = _findSections(m);
    final weeks = _findWeeks(m);

    if (dayOfWeek == null) return null;

    return Course(
      courseId: 'api_${name}_${dayOfWeek}_${sections[0]}',
      name: name,
      teacher: teacher ?? '',
      location: location ?? '',
      dayOfWeek: dayOfWeek,
      startSection: sections[0],
      endSection: sections[1],
      weeks: weeks ?? List.generate(16, (i) => i + 1),
      colorHex: _nc(),
      schoolSystem: 'api',
    );
  }

  String? _findField(Map m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.isNotEmpty && v.length < 50) return v.trim();
      if (v is int) return v.toString();
    }
    return null;
  }

  int? _findDayOfWeek(Map m) {
    for (final k in ['dayOfWeek', 'weekDay', 'xq', 'xqj', 'week', 'day', 'skxq', 'dayIndex']) {
      final v = m[k];
      if (v is int && v >= 1 && v <= 7) return v;
      if (v is String) {
        final n = int.tryParse(v);
        if (n != null && n >= 1 && n <= 7) return n;
        for (var i = 0; i < 7; i++) {
          final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日',
                       '星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日',
                       'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          if (v.contains(days[i]) || v.contains(days[i + 7])) return i + 1;
        }
      }
    }
    return null;
  }

  List<int> _findSections(Map m) {
    int ss = 1, ee = 2;
    for (final k in ['startSection', 'start', 'ksjc', 'jcs', 'sjd', 'beginSection']) {
      final v = m[k]; if (v is int && v >= 1 && v <= 12) ss = v;
      if (v is String) { final n = int.tryParse(v); if (n != null && n >= 1 && n <= 12) ss = n; }
    }
    for (final k in ['endSection', 'end', 'jsjc', 'jce', 'endSection']) {
      final v = m[k]; if (v is int && v >= ss && v <= 12) ee = v;
      if (v is String) { final n = int.tryParse(v); if (n != null && n >= ss && n <= 12) ee = n; }
    }
    return [ss, ee];
  }

  List<int>? _findWeeks(Map m) {
    for (final k in ['weeks', 'weekList', 'weekRange', 'zcs', 'weekIds']) {
      final v = m[k];
      if (v is List) {
        final weeks = v.map((e) => e is int ? e : int.tryParse(e.toString())).whereType<int>().toList();
        if (weeks.isNotEmpty) return weeks;
      }
      if (v is String) {
        // Try "1-16" or "1,2,3" formats
        final rangeMatch = RegExp(r'(\d+)\s*[-~–]\s*(\d+)').firstMatch(v);
        if (rangeMatch != null) {
          final a = int.parse(rangeMatch.group(1)!), b = int.parse(rangeMatch.group(2)!);
          return List.generate(b - a + 1, (i) => a + i);
        }
        final nums = RegExp(r'\d+').allMatches(v).map((m) => int.parse(m.group(0)!)).toList();
        if (nums.isNotEmpty) return nums;
      }
    }
    return null;
  }

  String _nc() {
    final c = ColorUtils.getByIndex(_ci); _ci++;
    return '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
  }
}
