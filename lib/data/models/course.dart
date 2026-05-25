import 'dart:convert';
class Course {
  final int? id;final String courseId;final String name;final String teacher;final String location;
  final int dayOfWeek;final int startSection;final int endSection;final List<int> weeks;
  final String colorHex;final String? remark;final String? schoolSystem;final int semesterId;
  const Course({this.id,required this.courseId,required this.name,this.teacher='',this.location='',required this.dayOfWeek,required this.startSection,required this.endSection,required this.weeks,required this.colorHex,this.remark,this.schoolSystem,this.semesterId=0});
  Course copyWith({int? id,String? courseId,String? name,String? teacher,String? location,int? dayOfWeek,int? startSection,int? endSection,List<int>? weeks,String? colorHex,String? remark,String? schoolSystem,int? semesterId})=>Course(id:id??this.id,courseId:courseId??this.courseId,name:name??this.name,teacher:teacher??this.teacher,location:location??this.location,dayOfWeek:dayOfWeek??this.dayOfWeek,startSection:startSection??this.startSection,endSection:endSection??this.endSection,weeks:weeks??this.weeks,colorHex:colorHex??this.colorHex,remark:remark??this.remark,schoolSystem:schoolSystem??this.schoolSystem,semesterId:semesterId??this.semesterId);
  Map<String,dynamic> toMap()=>{if(id!=null)'id':id,'courseId':courseId,'name':name,'teacher':teacher,'location':location,'dayOfWeek':dayOfWeek,'startSection':startSection,'endSection':endSection,'weeks':jsonEncode(weeks),'colorHex':colorHex,'remark':remark,'schoolSystem':schoolSystem,'semesterId':semesterId};
  factory Course.fromMap(Map<String,dynamic> m)=>Course(id:m['id'],courseId:m['courseId'],name:m['name'],teacher:m['teacher']??'',location:m['location']??'',dayOfWeek:m['dayOfWeek'],startSection:m['startSection'],endSection:m['endSection'],weeks:(jsonDecode(m['weeks'] as String) as List).cast<int>(),colorHex:m['colorHex'],remark:m['remark'],schoolSystem:m['schoolSystem'],semesterId:m['semesterId']??0);
  bool hasClassInWeek(int w)=>weeks.contains(w);
}
