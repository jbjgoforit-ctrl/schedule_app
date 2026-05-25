import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLocale { zh, en }

final localeProvider = StateProvider<AppLocale>((ref) => AppLocale.zh);

class S {
  final AppLocale locale;
  const S(this.locale);

  static S of(AppLocale l) => S(l);

  String get appName => locale == AppLocale.zh ? '我的课表' : 'My Schedule';
  String get import => locale == AppLocale.zh ? '导入课表' : 'Import';
  String get settings => locale == AppLocale.zh ? '设置' : 'Settings';
  String get today => locale == AppLocale.zh ? '回到本周' : 'Today';
  String get week => locale == AppLocale.zh ? '周' : 'Wk';
  String get addCourse => locale == AppLocale.zh ? '添加课程' : 'Add Course';
  String get editCourse => locale == AppLocale.zh ? '编辑课程' : 'Edit Course';
  String get delete => locale == AppLocale.zh ? '删除' : 'Delete';
  String get cancel => locale == AppLocale.zh ? '取消' : 'Cancel';
  String get save => locale == AppLocale.zh ? '保存' : 'Save';
  String get name => locale == AppLocale.zh ? '课程名称' : 'Course Name';
  String get teacher => locale == AppLocale.zh ? '授课教师' : 'Teacher';
  String get location => locale == AppLocale.zh ? '上课地点' : 'Location';
  String get dayOfWeek => locale == AppLocale.zh ? '星期' : 'Day';
  String get startSection => locale == AppLocale.zh ? '开始节次' : 'Start';
  String get endSection => locale == AppLocale.zh ? '结束节次' : 'End';
  String get weeks => locale == AppLocale.zh ? '上课周次' : 'Weeks';
  String get color => locale == AppLocale.zh ? '课程颜色' : 'Color';
  String get remark => locale == AppLocale.zh ? '备注' : 'Note';
  String get blockThisWeek => locale == AppLocale.zh ? '本周停课' : 'Skip Week';
  String get restoreThisWeek => locale == AppLocale.zh ? '本周复课' : 'Restore Week';
  String get darkMode => locale == AppLocale.zh ? '深色模式' : 'Dark Mode';
  String get language => locale == AppLocale.zh ? '语言' : 'Language';
  String get chinese => locale == AppLocale.zh ? '中文' : 'Chinese';
  String get english => locale == AppLocale.zh ? 'English' : 'English';
  String get proxy => locale == AppLocale.zh ? '校园网代理' : 'Proxy/VPN';
  String get classTimes => locale == AppLocale.zh ? '每节上课时间' : 'Class Times';
  String get htmlImport => locale == AppLocale.zh ? '粘贴HTML源码导入' : 'Paste HTML';
  String get webviewImport => locale == AppLocale.zh ? '账号密码导入' : 'Account Login';
  String get preview => locale == AppLocale.zh ? '预览' : 'Preview';
  String get saveToSchedule => locale == AppLocale.zh ? '保存到课表' : 'Save';
  String get clear => locale == AppLocale.zh ? '清除' : 'Clear';
  String get courseDetail => locale == AppLocale.zh ? '课程详情' : 'Details';
  String get loadFail => locale == AppLocale.zh ? '加载课程失败' : 'Load Failed';
  String get tapAddHint => locale == AppLocale.zh ? '点击空格添加课程' : 'Tap cell to add';
  String get importFail => locale == AppLocale.zh ? '导入失败' : 'Import Failed';
  String get loginHint => locale == AppLocale.zh
      ? '登录后请导航到个人课表页面并选择正确学期'
      : 'Login and navigate to schedule page';
  String get noCourseData => locale == AppLocale.zh
      ? '未检测到课表数据，请确认已登录到个人课表页面'
      : 'No schedule data found';
  String get directUrl => locale == AppLocale.zh ? '直接输入教务网站地址' : 'Enter教务 URL';
  String get orPickSchool => locale == AppLocale.zh ? '或者选学校' : 'Or Pick School';
  String get pickSchool => locale == AppLocale.zh ? '选择学校快速填入' : 'Pick School';
  String get searchSchool => locale == AppLocale.zh ? '搜索学校名称...' : 'Search...';
  String get goToJw => locale == AppLocale.zh ? '前往教务系统' : 'Open教务';
  String get info => locale == AppLocale.zh ? '基本信息' : 'Info';
  String get time => locale == AppLocale.zh ? '上课时间' : 'Time';
  String get section => locale == AppLocale.zh ? '节次' : 'Section';
  String get place => locale == AppLocale.zh ? '上课地点' : 'Place';
  String get all => locale == AppLocale.zh ? '全选' : 'All';
  String get schedule => locale == AppLocale.zh ? '课表设置' : 'Schedule';
  String get notifications => locale == AppLocale.zh ? '通知' : 'Notifications';
  String get data => locale == AppLocale.zh ? '数据' : 'Data';
  String get about => locale == AppLocale.zh ? '关于' : 'About';
  String get version => locale == AppLocale.zh ? '版本' : 'Version';
}
