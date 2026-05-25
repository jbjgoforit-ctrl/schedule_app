import 'package:flutter/material.dart';
import '../../../data/models/course.dart';
import '../../../core/constants/app_text_styles.dart';
class CourseCardWidget extends StatelessWidget {
  final Course course;final Color color;final bool compact;
  const CourseCardWidget({super.key, required this.course, required this.color, this.compact = false});
  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 2, offset: const Offset(0, 1))]), padding: const EdgeInsets.all(3), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      if (!compact) Text(course.name, style: AppTextStyles.courseTitle.copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis) else Text(course.name, style: AppTextStyles.courseTitle.copyWith(fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
      if (course.location.isNotEmpty) Text(course.location, style: AppTextStyles.courseInfo.copyWith(fontSize: compact ? 9 : 10), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]));
  }
}
