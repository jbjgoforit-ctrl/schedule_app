import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/course.dart';
class DatabaseHelper {
  static DatabaseHelper? _i;static Database? _db;final List<Course> _courses=[];int _nid=1;
  DatabaseHelper._();factory DatabaseHelper()=>_i??=DatabaseHelper._();
  bool get _w=>kIsWeb;
  Future<Database> get database async{if(_w)throw UnsupportedError('web');_db??=await _init();return _db!;}
  Future<Database> _init()async{final p=join(await getDatabasesPath(),'schedule.db');return openDatabase(p,version:1,onCreate:_onCreate);}
  Future<void> _onCreate(Database db,int v)async{await db.execute('CREATE TABLE courses(id INTEGER PRIMARY KEY AUTOINCREMENT,courseId TEXT NOT NULL,name TEXT NOT NULL,teacher TEXT DEFAULT "",location TEXT DEFAULT "",dayOfWeek INTEGER NOT NULL,startSection INTEGER NOT NULL,endSection INTEGER NOT NULL,weeks TEXT NOT NULL,colorHex TEXT NOT NULL,remark TEXT,schoolSystem TEXT,semesterId INTEGER DEFAULT 0)');}
  Future<int> insertCourse(Course c)async{if(_w){final n=c.copyWith(id:_nid++);_courses.add(n);return n.id!;}final db=await database;return db.insert('courses',c.toMap()..remove('id'));}
  Future<List<Course>> getAllCourses({int sid=0})async{if(_w)return _courses.where((c)=>c.semesterId==sid).toList();final db=await database;final m=await db.query('courses',where:'semesterId=?',whereArgs:[sid]);return m.map(Course.fromMap).toList();}
  Future<List<Course>> getCoursesByDay(int d,{int sid=0})async{if(_w)return _courses.where((c)=>c.dayOfWeek==d&&c.semesterId==sid).toList()..sort((a,b)=>a.startSection.compareTo(b.startSection));final db=await database;final m=await db.query('courses',where:'dayOfWeek=? AND semesterId=?',whereArgs:[d,sid],orderBy:'startSection ASC');return m.map(Course.fromMap).toList();}
  Future<int> updateCourse(Course c)async{if(_w){final i=_courses.indexWhere((x)=>x.id==c.id);if(i!=-1)_courses[i]=c;return 1;}final db=await database;return db.update('courses',c.toMap(),where:'id=?',whereArgs:[c.id]);}
  Future<int> deleteCourse(int id)async{if(_w){_courses.removeWhere((c)=>c.id==id);return 1;}final db=await database;return db.delete('courses',where:'id=?',whereArgs:[id]);}
  Future<void> insertCourses(List<Course> cs)async{if(_w){for(final c in cs)_courses.add(c.copyWith(id:_nid++));return;}final db=await database;final b=db.batch();for(final c in cs)b.insert('courses',c.toMap()..remove('id'));await b.commit(noResult:true);}
  Future<void> deleteAllCourses({int sid=0})async{if(_w){_courses.removeWhere((c)=>c.semesterId==sid);return;}final db=await database;await db.delete('courses',where:'semesterId=?',whereArgs:[sid]);}
}
