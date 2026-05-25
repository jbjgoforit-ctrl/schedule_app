import '../../../data/models/course.dart';
class ScheduleState {
  final int currentWeek;final Map<int, List<Course>> weeklyCourses;final bool isLoading;final String? errorMessage;final DateTime? semesterStartDate;
  const ScheduleState({required this.currentWeek, this.weeklyCourses = const {}, this.isLoading = false, this.errorMessage, this.semesterStartDate});
  factory ScheduleState.initial() => ScheduleState(currentWeek: 1, weeklyCourses: const {}, isLoading: false);
  ScheduleState copyWith({int? currentWeek, Map<int, List<Course>>? weeklyCourses, bool? isLoading, String? errorMessage, DateTime? semesterStartDate}) => ScheduleState(currentWeek: currentWeek ?? this.currentWeek, weeklyCourses: weeklyCourses ?? this.weeklyCourses, isLoading: isLoading ?? this.isLoading, errorMessage: errorMessage, semesterStartDate: semesterStartDate ?? this.semesterStartDate);
}
