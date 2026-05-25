import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/datasources/remote/jw_login_service.dart';
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) => SettingsNotifier());
class SettingsState {
  final bool isDarkMode;final bool showWeekends;final bool enableNotifications;
  final int notificationMinutes;final int maxSectionsPerDay;final String currentSemesterName;
  final ProxyConfig proxy;final Map<int, String> sectionTimes;final String locale;
  const SettingsState({this.isDarkMode=false,this.showWeekends=true,this.enableNotifications=true,this.notificationMinutes=15,this.maxSectionsPerDay=12,this.currentSemesterName='2025-2026 第二学期',this.proxy=const ProxyConfig(),this.sectionTimes=const{1:'08:00',2:'08:55',3:'10:00',4:'10:55',5:'13:30',6:'14:25',7:'15:30',8:'16:25',9:'18:20',10:'19:06',11:'20:00',12:'20:46'},this.locale='zh'});
  SettingsState copyWith({bool? isDarkMode,bool? showWeekends,bool? enableNotifications,int? notificationMinutes,int? maxSectionsPerDay,String? currentSemesterName,ProxyConfig? proxy,Map<int,String>? sectionTimes,String? locale})=>SettingsState(isDarkMode:isDarkMode??this.isDarkMode,showWeekends:showWeekends??this.showWeekends,enableNotifications:enableNotifications??this.enableNotifications,notificationMinutes:notificationMinutes??this.notificationMinutes,maxSectionsPerDay:maxSectionsPerDay??this.maxSectionsPerDay,currentSemesterName:currentSemesterName??this.currentSemesterName,proxy:proxy??this.proxy,sectionTimes:sectionTimes??this.sectionTimes,locale:locale??this.locale);
}
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {_load();}
  Future<void> _load() async {final p=await SharedPreferences.getInstance();state=SettingsState(isDarkMode:p.getBool('isDarkMode')??false,showWeekends:p.getBool('showWeekends')??true,enableNotifications:p.getBool('enableNotifications')??true,notificationMinutes:p.getInt('notificationMinutes')??15,maxSectionsPerDay:p.getInt('maxSectionsPerDay')??12,proxy:ProxyConfig(enabled:p.getBool('proxyEnabled')??false,host:p.getString('proxyHost')??'',port:p.getInt('proxyPort')??1080,username:p.getString('proxyUser')??'',password:p.getString('proxyPass')??''),sectionTimes:_loadTimes(p),locale:p.getString('locale')??'zh');}
  Map<int,String> _loadTimes(SharedPreferences p){final j=p.getString('sectionTimes');if(j==null)return state.sectionTimes;try{final m=jsonDecode(j) as Map<String,dynamic>;return m.map((k,v)=>MapEntry(int.parse(k),v.toString()));}catch(e){return state.sectionTimes;}}
  Future<void> _save() async {final p=await SharedPreferences.getInstance();await p.setBool('isDarkMode',state.isDarkMode);await p.setBool('showWeekends',state.showWeekends);await p.setBool('enableNotifications',state.enableNotifications);await p.setInt('notificationMinutes',state.notificationMinutes);await p.setInt('maxSectionsPerDay',state.maxSectionsPerDay);await p.setBool('proxyEnabled',state.proxy.enabled);await p.setString('proxyHost',state.proxy.host);await p.setInt('proxyPort',state.proxy.port);await p.setString('proxyUser',state.proxy.username??'');await p.setString('proxyPass',state.proxy.password??'');await p.setString('sectionTimes',jsonEncode(state.sectionTimes.map((k,v)=>MapEntry(k.toString(),v))));await p.setString('locale',state.locale);}
  void toggleDarkMode(){state=state.copyWith(isDarkMode:!state.isDarkMode);_save();}
  void toggleWeekends(){state=state.copyWith(showWeekends:!state.showWeekends);_save();}
  void toggleNotifications(){state=state.copyWith(enableNotifications:!state.enableNotifications);_save();}
  void setNotificationMinutes(int m){state=state.copyWith(notificationMinutes:m);_save();}
  void setMaxSections(int s){state=state.copyWith(maxSectionsPerDay:s);_save();}
  void setSectionTime(int section,String time){final nt=Map<int,String>.from(state.sectionTimes);nt[section]=time;state=state.copyWith(sectionTimes:nt);_save();}
  void setProxy(ProxyConfig p){state=state.copyWith(proxy:p);_save();}
  void setLocale(String l){state=state.copyWith(locale:l);_save();}
  void clearAllData() async {final p=await SharedPreferences.getInstance();await p.clear();state=const SettingsState();}
}
