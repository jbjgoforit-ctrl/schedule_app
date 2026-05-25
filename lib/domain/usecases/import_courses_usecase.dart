import 'dart:typed_data';
import '../../data/models/course.dart';import '../../data/models/import_result.dart';
import '../../data/datasources/remote/jw_system_parser.dart';
import '../../data/datasources/remote/jw_login_service.dart';
import '../../data/datasources/remote/ics_parser.dart';
import '../../data/repositories/course_repository.dart';
class ImportCoursesUseCase {
  final CourseRepository _repo;final JwSystemParser _htmlParser;final IcsParser _icsParser;JwLoginService? _ls;
  ImportCoursesUseCase(this._repo):_htmlParser=JwSystemParser(),_icsParser=IcsParser();
  Future<Uint8List?> getCaptcha({required String schoolUrl,required String st,ProxyConfig? proxy})async{_ls=JwLoginService(proxy:proxy,systemType:st);return _ls!.fetchCaptcha(schoolUrl);}
  Future<ImportResult> loginAndFetch({required String schoolUrl,required String username,required String password,required String captcha,String st='zhengfang',ProxyConfig? proxy,int sid=0})async{final ls=_ls??JwLoginService(proxy:proxy,systemType:st);try{if(_ls==null)await ls.fetchCaptcha(schoolUrl);final ok=await ls.login(username:username,password:password,captcha:captcha);if(!ok)return ImportResult.failure('login failed');final html=await ls.fetchScheduleHtml();if(html==null||html.isEmpty)return ImportResult.failure('no schedule html');return _htmlParser.parseHtml(html,st);}catch(e){return ImportResult.failure('err: $e');}}
  ImportResult importFromHtml(String html,String st)=>_htmlParser.parseHtml(html,st);
  ImportResult importFromIcs(String ics)=>_icsParser.parse(ics);
  Future<ImportResult> saveImportedCourses(List<Course> c,{int sid=0})=>_repo.importCourses(c,sid:sid);
  void reset(){_ls?.reset();_ls=null;}
}
