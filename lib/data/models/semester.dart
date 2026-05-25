class Semester {
  final int? id;final String name;final DateTime startDate;final int totalWeeks;
  const Semester({this.id,required this.name,required this.startDate,this.totalWeeks=20});
  Map<String,dynamic> toMap()=>{if(id!=null)'id':id,'name':name,'startDate':startDate.toIso8601String(),'totalWeeks':totalWeeks};
  factory Semester.fromMap(Map<String,dynamic> m)=>Semester(id:m['id'],name:m['name'],startDate:DateTime.parse(m['startDate']),totalWeeks:m['totalWeeks']??20);
}
