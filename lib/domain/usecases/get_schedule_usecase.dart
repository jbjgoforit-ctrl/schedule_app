import '../../data/models/course.dart';
import '../../data/repositories/course_repository.dart';
class GetScheduleUseCase {
  final CourseRepository _repo;GetScheduleUseCase(this._repo);
  Future<List<Course>> getWeekSchedule(int week,{int sid=0})async{final all=await _repo.getAllCourses(sid:sid);return all.where((c)=>c.hasClassInWeek(week)).toList();}
  Future<Map<int,List<Course>>> getWeeklyGrid(int week,{int sid=0})async{final wc=await getWeekSchedule(week,sid:sid);final g=<int,List<Course>>{};for(var d=1;d<=7;d++){g[d]=wc.where((c)=>c.dayOfWeek==d).toList()..sort((a,b)=>a.startSection.compareTo(b.startSection));}return g;}
}
