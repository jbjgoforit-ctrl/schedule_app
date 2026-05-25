import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'schedule_provider.dart';
import 'week_view_widget.dart';
import '../../settings/domain/settings_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduleStateProvider);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppConstants.appName), actions: [
        IconButton(icon: const Icon(Icons.today), tooltip: '回到本周', onPressed: () => ref.read(scheduleStateProvider.notifier).goToToday()),
        IconButton(icon: const Icon(Icons.file_download_outlined), tooltip: '导入课表', onPressed: () => context.pushNamed('import')),
      ]),
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          if (d.primaryVelocity != null) {
            if (d.primaryVelocity! < -50) ref.read(scheduleStateProvider.notifier).nextWeek();
            else if (d.primaryVelocity! > 50) ref.read(scheduleStateProvider.notifier).previousWeek();
          }
        },
        child: Column(children: [
          _buildWeekSelector(ref, state.currentWeek),
          if (state.isLoading) const LinearProgressIndicator()
          else if (state.errorMessage != null) _buildErrorView(state.errorMessage!)
          else Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: WeekViewWidget(coursesByDay: state.weeklyCourses, currentWeek: state.currentWeek, sectionTimes: settings.sectionTimes, semesterStart: state.semesterStartDate ?? DateTime(DateTime.now().year, 2, 1)))),
        ]),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {final result = await context.pushNamed('course_add');if(result==true)ref.read(scheduleStateProvider.notifier).loadCourses();}, child: const Icon(Icons.add)),
    );
  }
  Widget _buildWeekSelector(WidgetRef ref, int currentWeek) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), decoration: BoxDecoration(color: Theme.of(ref.context).scaffoldBackgroundColor, border: const Border(bottom: BorderSide(color: AppColors.divider, width: 0.5))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      IconButton(icon: const Icon(Icons.chevron_left, size: 20), onPressed: () => ref.read(scheduleStateProvider.notifier).previousWeek(), style: IconButton.styleFrom(backgroundColor: AppColors.surfaceVariant, minimumSize: const Size(32, 32))),
      const SizedBox(width: 12),
      Text('第 $currentWeek 周', style: AppTextStyles.heading3),
      const SizedBox(width: 12),
      IconButton(icon: const Icon(Icons.chevron_right, size: 20), onPressed: () => ref.read(scheduleStateProvider.notifier).nextWeek(), style: IconButton.styleFrom(backgroundColor: AppColors.surfaceVariant, minimumSize: const Size(32, 32))),
    ]));
  }
  Widget _buildErrorView(String message) {
    return Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 48, color: AppColors.error), const SizedBox(height: 16), Text(message, style: AppTextStyles.body)])));
  }
}
