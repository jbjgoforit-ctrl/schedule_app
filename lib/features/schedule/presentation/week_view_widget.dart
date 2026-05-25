import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/course.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'course_card_widget.dart';

class WeekViewWidget extends StatelessWidget {
  final Map<int, List<Course>> coursesByDay;
  final int currentWeek;
  final Map<int, String> sectionTimes;
  final DateTime semesterStart;

  const WeekViewWidget({
    super.key,
    required this.coursesByDay,
    required this.currentWeek,
    this.sectionTimes = const {},
    required this.semesterStart,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(children: [
        _buildDayHeader(today, isDark),
        SizedBox(
          height: AppConstants.maxSectionsPerDay * 72.0,
          child: Row(children: [
            SizedBox(
              width: 44,
              child: Column(
                children: List.generate(
                  AppConstants.maxSectionsPerDay,
                  (i) => _buildTimeCell(i + 1, isDark),
                ),
              ),
            ),
            Expanded(
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final dayOfWeek = dayIndex + 1;
                  final dayCourses = coursesByDay[dayOfWeek] ?? [];
                  return Expanded(
                    child: _buildDayColumn(
                      dayCourses,
                      dayOfWeek,
                      today,
                      isDark,
                      context,
                    ),
                  );
                }),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _buildDayHeader(int today, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(left: 44),
      height: 48,
      child: Row(
        children: List.generate(7, (index) {
          final dayOfWeek = index + 1;
          final isToday = dayOfWeek == today;
          final date = semesterStart.add(Duration(days: (currentWeek - 1) * 7 + index));
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isToday
                    ? AppColors.primary.withOpacity(isDark ? 0.3 : 0.08)
                    : Colors.transparent,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${date.month}/${date.day}',
                  style: TextStyle(fontSize: 10, fontWeight: isToday ? FontWeight.bold : FontWeight.w400, color: isToday ? AppColors.primary : (isDark ? Colors.white38 : AppColors.textHint)),
                ),
                Text(AppConstants.weekDayNames[index],
                  style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.bold : FontWeight.w500, color: isToday ? AppColors.primary : (isDark ? Colors.white54 : AppColors.textSecondary)),
                ),
              ]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeCell(int section, bool isDark) {
    final t = sectionTimes[section] ?? '$section';
    return SizedBox(
      height: 72,
      child: Center(
        child: Text(
          t,
          style: TextStyle(
            fontSize: 9,
            color: isDark ? Colors.white30 : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildDayColumn(
    List<Course> courses,
    int dayOfWeek,
    int today,
    bool isDark,
    BuildContext context,
  ) {
    final isToday = dayOfWeek == today;

    // Find occupied sections
    final occupiedSections = <int>{};
    for (final c in courses) {
      for (var s = c.startSection; s <= c.endSection; s++) {
        occupiedSections.add(s);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary.withOpacity(isDark ? 0.05 : 0.03)
            : Colors.transparent,
        border: Border(
          left: dayOfWeek > 1
              ? BorderSide(
                  color: isDark ? Colors.white10 : AppColors.divider,
                  width: 0.5,
                )
              : BorderSide.none,
        ),
      ),
      child: Stack(
        children: [
          // Grid lines + empty cell tap zones
          ...List.generate(AppConstants.maxSectionsPerDay, (i) {
            final section = i + 1;
            final hasCourse = occupiedSections.contains(section);
            return Positioned(
              top: i * 72.0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: hasCourse
                    ? null
                    : () => context.pushNamed('course_add',
                        extra: {'day': dayOfWeek, 'section': section}),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? Colors.white10 : AppColors.divider,
                        width: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          // Course cards
          ...courses.map((course) => _buildPositionedCourse(course, context)),
        ],
      ),
    );
  }

  Widget _buildPositionedCourse(Course course, BuildContext context) {
    final top = (course.startSection - 1) * 72.0;
    final height = (course.endSection - course.startSection + 1) * 72.0;
    final color = _parseColor(course.colorHex);

    return Positioned(
      top: top + 1,
      left: 1,
      right: 1,
      height: height - 2,
      child: GestureDetector(
        onTap: () {
          if (course.id != null) {
            context.pushNamed('course_edit',
                pathParameters: {'id': '${course.id}'});
          }
        },
        onLongPress: () {
          if (course.id != null) {
            context.push('/course/${course.id}');
          }
        },
        child: CourseCardWidget(
          course: course,
          color: color,
          compact: height < 80,
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}
