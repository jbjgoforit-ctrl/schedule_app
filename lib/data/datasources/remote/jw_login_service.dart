import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'proxy_setup.dart' if (dart.library.io) 'proxy_setup_native.dart';
import 'school_sites.dart';
class ProxyConfig {
  final bool enabled;final String host;final int port;final String? username;final String? password;
  const ProxyConfig({this.enabled=false,this.host='',this.port=1080,this.username,this.password});
  ProxyConfig copyWith({bool? enabled,String? host,int? port,String? username,String? password})=>ProxyConfig(enabled:enabled??this.enabled,host:host??this.host,port:port??this.port,username:username??this.username,password:password??this.password);
}
class JwLoginService {
  final ProxyConfig proxy;final String systemType;Dio? _dio;String _schoolUrl='';String _cookie='';Map<String,String> _hidden={};Uint8List? _captcha;
  JwLoginService({ProxyConfig? proxy,this.systemType='zhengfang'}):proxy=proxy??const ProxyConfig();
  Future<Uint8List?> fetchCaptcha(String schoolUrl)async{_schoolUrl=schoolUrl.endsWith('/')?schoolUrl.substring(0,schoolUrl.length-1):schoolUrl;_dio=_mkDio();try{for(final path in _loginPaths()){try{final r=await _dio!.get('$_schoolUrl$path');if(r.statusCode==200){_extractCookies(r);_extractHidden(r.data.toString());_captcha=await _dlCaptcha();if(_captcha!=null)return _captcha;}}catch(_){continue;}}return _captcha;}catch(e){return null;}}
  Future<bool> login({required String username,required String password,String captcha=''})async{if(_dio==null)return false;try{final r=await _dio!.post('$_schoolUrl${_loginPostPath()}',data:_buildLoginData(username,password,captcha),options:Options(headers:{'Content-Type':'application/x-www-form-urlencoded','Referer':'$_schoolUrl${_loginPaths().first}',if(_cookie.isNotEmpty)'Cookie':_cookie}));_extractCookies(r);final body=r.data.toString();final failKws=['错误','失败','密码不正确','验证码','帐号不存在','error','fail'];final isFail=failKws.any((k)=>body.contains(k))&&!body.contains('课表');return r.statusCode==200&&!isFail;}catch(e){return false;}}
  Future<String?> fetchScheduleHtml()async{if(_dio==null)return null;for(final path in _schedulePaths()){try{final r=await _dio!.get('$_schoolUrl$path',options:Options(headers:{'Referer':'$_schoolUrl${_loginPaths().first}',if(_cookie.isNotEmpty)'Cookie':_cookie}));if(r.statusCode==200){final body=r.data.toString();if(_looksLikeSchedule(body))return body;}}catch(_){continue;}}return null;}
  Future<String?> loginAndFetch({required String schoolUrl,required String username,required String password,String captcha=''})async{if(_dio==null)await fetchCaptcha(schoolUrl);final ok=await login(username:username,password:password,captcha:captcha);if(!ok)return null;return fetchScheduleHtml();}
  JwSystemTemplate get _tmpl{try{return JwSystemTemplate.all.firstWhere((t)=>t.id==systemType);}catch(_){return JwSystemTemplate.all.last;}}
  List<String> _loginPaths(){return[_tmpl.loginPath];}
  String _loginPostPath(){return _tmpl.loginPath;}
  List<String> _schedulePaths(){return _tmpl.schedulePaths;}
  List<String> _captchaPaths(){return _tmpl.captchaPaths;}
  Map<String,String> _buildLoginData(String u,String p,String c){switch(systemType){case'zhengfang':return{'__VIEWSTATE':_hidden['__VIEWSTATE']??'','txtUserName':u,'TextBox2':p,'txtSecretCode':c,'RadioButtonList1':Uri.encodeComponent('学生'),'Button1':''};case'qiangzhi':return{'yhm':u,'mm':p,'yzm':c};default:return{'username':u,'password':p,'captcha':c};}}
  void _extractCookies(Response r){final sc=r.headers.map['set-cookie'];if(sc!=null){_cookie=sc.map((c)=>c.split(';').first).join('; ');}}
  void _extractHidden(String html){final re=RegExp(r'<input[^>]*name="(.*?)"[^>]*value="([^"]*)"',caseSensitive:false);for(final m in re.allMatches(html)){_hidden[m.group(1)!]=m.group(2)!;}}
  Future<Uint8List?> _dlCaptcha()async{if(_dio==null)return null;final paths=_captchaPaths();for(final path in paths){try{final r=await _dio!.get('$_schoolUrl$path',options:Options(responseType:ResponseType.bytes,headers:{if(_cookie.isNotEmpty)'Cookie':_cookie}));if(r.statusCode==200&&r.data is List<int>)return Uint8List.fromList(r.data as List<int>);}catch(_){continue;}}return null;}
  bool _looksLikeSchedule(String html){final kw=['课表','课程','星期','周一','周二','教师','教室','上课','节次','周次','kbtable','course','schedule'];final cnt=kw.where((k)=>html.contains(k)).length;return cnt>=3;}
  Dio _mkDio(){final dio=Dio(BaseOptions(connectTimeout:const Duration(seconds:30),receiveTimeout:const Duration(seconds:30),followRedirects:true,validateStatus:(s)=>s!=null&&s<500,headers:{'User-Agent':'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36','Accept':'text/html,application/xhtml+xml','Accept-Language':'zh-CN,zh;q=0.9'}));if(proxy.enabled&&proxy.host.isNotEmpty)setupProxy(dio,proxy);return dio;}
  void reset(){_dio=null;_cookie='';_hidden={};_captcha=null;}
}
