import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/schedule_state.dart';
import '../../../domain/usecases/get_schedule_usecase.dart';
import '../../import/presentation/import_provider.dart';
final scheduleUseCaseProvider = Provider<GetScheduleUseCase>((ref) {final r = ref.watch(courseRepositoryProvider);return GetScheduleUseCase(r);});
final scheduleStateProvider = StateNotifierProvider<ScheduleNotifier, ScheduleState>((ref) {final uc = ref.watch(scheduleUseCaseProvider);return ScheduleNotifier(uc);});
class ScheduleNotifier extends StateNotifier<ScheduleState> {
  final GetScheduleUseCase _uc;int _sid = 0;
  ScheduleNotifier(this._uc) : super(ScheduleState.initial()) {_init();}
  Future<void> _init() async {final now = DateTime.now();final ss = DateTime(now.year, now.month >= 9 ? 9 : 2, 1);final cw = ((now.difference(ss).inDays) / 7).ceil().clamp(1, 20);state = state.copyWith(currentWeek: cw, semesterStartDate: ss);await loadCourses();}
  Future<void> loadCourses() async {state = state.copyWith(isLoading: true);try {final grid = await _uc.getWeeklyGrid(state.currentWeek, sid: _sid);state = state.copyWith(isLoading: false, weeklyCourses: grid, errorMessage: null);} catch (e) {state = state.copyWith(isLoading: false, errorMessage: 'load fail: $e');}}
  void setWeek(int w) {if (w < 1 || w > 20) return;state = state.copyWith(currentWeek: w);loadCourses();}
  void previousWeek() {if (state.currentWeek > 1) setWeek(state.currentWeek - 1);}
  void nextWeek() {if (state.currentWeek < 20) setWeek(state.currentWeek + 1);}
  void goToToday() {final now = DateTime.now();final ss = state.semesterStartDate ?? DateTime(now.year, 2, 1);final cw = ((now.difference(ss).inDays) / 7).ceil().clamp(1, 20);setWeek(cw);}
}
