import 'package:html/parser.dart' show parse;
import '../../models/course.dart';import '../../models/import_result.dart';import '../../../core/utils/color_utils.dart';

class JwSystemParser {
  int _ci=0;

  ImportResult parseHtml(String html,String st){
    _ci=0;
    try{
      final doc=parse(html);
      final allText=doc.body?.text??'';
      if(allText.isEmpty||allText.length<20)
        return ImportResult.failure('Page too short. Are you on the schedule page?');
      if(allText.contains('密码错误')||allText.contains('验证码错误'))
        return ImportResult.failure('Login failed. Check password/captcha.');

      List<Course> c=[];
      // Strategy 0: JWApp wut_table format (新一代教务)
      c=_parseJwApp(doc);
      if(c.isNotEmpty)return ImportResult.success(c);
      // Strategy 1: Known formats
      c=_parseTable1(doc,'#Table1');
      if(c.isNotEmpty)return ImportResult.success(c);
      // Strategy 2: Any table with row/column grid
      c=_parseAnyTable(doc);
      if(c.isNotEmpty)return ImportResult.success(c);
      // Strategy 3: Text scan fallback
      c=_parseByTextScan(allText);
      if(c.isNotEmpty)return ImportResult.success(c);

      final plainText=html.replaceAll(RegExp(r'<[^>]*>'),' ').replaceAll(RegExp(r'&[a-z]+;'),' ').replaceAll(RegExp(r'\s+'),' ').trim();
      final preview=plainText.length>300?plainText.substring(0,300):plainText;
      return ImportResult.failure('No courses found. If your school uses dynamic JS loading, try: 1) Wait 5s after page loads then tap import again 2) Use "Paste HTML" method from PC browser.\n\nPage text:\n$preview');
    }catch(e){
      return ImportResult.failure('Error: $e');
    }
  }

  // ── Strategy 0: JWApp wut_table (新一代教务) ──
  List<Course> _parseJwApp(doc){
    if(!doc.outerHtml.contains('mtt_arrange_item'))return[];
    final items=doc.querySelectorAll('td[data-role="item"]');
    if(items.isEmpty)return[];
    final c=<Course>[];
    final seen=<String>{};
    for(final td in items){
      final dow=int.tryParse(td.attributes['data-week']??'')??0;
      final ss=int.tryParse(td.attributes['data-begin-unit']??'')??0;
      final ee=int.tryParse(td.attributes['data-end-unit']??'')??ss;
      if(dow<1||dow>7||ss<1)continue;
      final cards=td.querySelectorAll('.mtt_arrange_item');
      for(final card in cards){
        final nameEl=card.querySelector('.mtt_item_kcmc');
        final teacherEl=card.querySelector('.mtt_item_jxbmc');
        final roomEl=card.querySelector('.mtt_item_room');
        if(nameEl==null)continue;
        final name=_cleanName(nameEl.text);
        if(name.isEmpty)continue;
        final teacher=teacherEl!=null?_cleanText(teacherEl.text):'';
        final roomText=roomEl!=null?_cleanText(roomEl.text):'';
        // Parse room text: "10-11周,星期3,第1节-第2节,南岭-逸夫楼-B614"
        final wi=_parseRoomText(roomText);
        final weeks=wi['weeks']??List.generate(16,(i)=>i+1);
        final loc=wi['location']??'';
        final key='$name|$dow|${wi['start']??ss}|${wi['end']??ee}';
        if(seen.contains(key))continue;
        seen.add(key);
        c.add(Course(courseId:'jwapp_${name}_$_ci',name:name,teacher:teacher,location:loc,dayOfWeek:dow,startSection:wi['start']??ss,endSection:wi['end']??ee,weeks:weeks,colorHex:_nc(),schoolSystem:'jwapp'));
      }
    }
    return c;
  }

  Map<String,dynamic> _parseRoomText(String t){
    int? s,e;List<int>? w;String loc='';
    // "10-11周,星期3,第1节-第2节,南岭-逸夫楼-B614"
    // or "5-7周,9-11周,星期2,第7节-第8节,南岭-逸夫楼-B322"
    // Extract week info: "10-11周" or "5-7周,9-11周"
    final weekParts=<int>[];
    for(final m in RegExp(r'(\d+)\s*[-~–]\s*(\d+)\s*周').allMatches(t)){
      final a=int.tryParse(m.group(1)!)??0;
      final b=int.tryParse(m.group(2)!)??0;
      if(a>0&&b>0)weekParts.addAll(List.generate(b-a+1,(i)=>a+i));
    }
    if(weekParts.isNotEmpty)w=weekParts;
    // Single week: "16周"
    if(w==null){
      final sm=RegExp(r'(\d+)\s*周').firstMatch(t);
      if(sm!=null){final a=int.tryParse(sm.group(1)!);if(a!=null&&a>0)w=[a];}
    }
    // Sections: "第1节-第2节"
    final secM=RegExp(r'第\s*(\d+)\s*节\s*[-~–]\s*第\s*(\d+)\s*节').firstMatch(t);
    if(secM!=null){s=int.tryParse(secM.group(1)!)??s;e=int.tryParse(secM.group(2)!)??e;}
    // Location: everything after the last节-第X节 pattern or last time info
    final locStart=t.lastIndexOf('节,')+2;
    if(locStart>2&&locStart<t.length)loc=t.substring(locStart).trim();
    if(loc.isEmpty||loc.contains('星期')){
      // Try splitting by comma and taking last meaningful part
      final parts=t.split(',');
      for(var i=parts.length-1;i>=0;i--){
        final p=parts[i].trim();
        if(!p.contains('周')&&!p.contains('星期')&&!p.contains('第')&&p.length>1){
          loc=p;break;
        }
      }
    }
    return{'start':s,'end':e,'weeks':w,'location':loc};
  }

  String _cleanName(String txt){
    txt=txt.replaceAll(RegExp(r'\[\d+\]'),'').trim(); // Remove [02] etc.
    return txt;
  }

  String _cleanText(String txt)=>txt.replaceAll(RegExp(r'\s+'),' ').trim();

  // ── Strategy 1: Classic 正方 #Table1 ──
  List<Course> _parseTable1(doc,String sel){
    final t=doc.querySelector(sel);if(t==null)return[];
    final rows=t.querySelectorAll('tr');if(rows.length<2)return[];
    final c=<Course>[];
    for(var i=1;i<rows.length;i++){
      final cells=rows[i].querySelectorAll('td,th');
      for(var col=0;col<cells.length;col++){
        final txt=cells[col].text.trim();
        if(txt.isEmpty||txt=='&nbsp;')continue;
        final dow=_mapDay(col,cells.length);
        if(dow<1||dow>7)continue;
        c.addAll(_parseCell(txt,dow,i+1));
      }
    }
    return c;
  }

  // ── Strategy 2: Any HTML table ──
  List<Course> _parseAnyTable(doc){
    final tables=doc.querySelectorAll('table');
    for(final t in tables){
      final rows=t.querySelectorAll('tr');
      if(rows.length<3)continue;

      // First pass: find header row to determine column→day mapping
      Map<int,int> colToDay={};
      int sectionCol=-1;
      for(var ri=0;ri<rows.length&&ri<5;ri++){
        final cells=rows[ri].querySelectorAll('td,th');
        for(var ci=0;ci<cells.length;ci++){
          final txt=cells[ci].text.trim();
          if(txt.contains('节次')||txt.contains('时间'))sectionCol=ci;
          for(var k=0;k<7;k++){
            final days=['周一','周二','周三','周四','周五','周六','周日'];
            if(txt.contains(days[k]))colToDay[ci]=k+1;
          }
        }
        if(colToDay.isNotEmpty)break;
      }

      // If no day headers found, assume columns 1-7 = Mon-Sun
      if(colToDay.isEmpty){
        for(var ci=0;ci<7;ci++)colToDay[ci+1]=ci+1;
      }

      // Second pass: parse data rows
      final c=<Course>[];
      Map<int,int> sectionForRow={};

      for(var ri=0;ri<rows.length;ri++){
        final cells=rows[ri].querySelectorAll('td,th');
        final texts=cells.map((e)=>e.text.trim()).toList();

        // Skip pure header rows
        final isHeader=texts.any((x)=>x.contains('星期')||x.contains('周次')&&!x.contains('第'));
        if(isHeader&&c.isEmpty)continue;

        // Try to extract section number from first column
        for(final txt in texts){
          final secMatch=RegExp(r'第\s*(\d+)\s*节').firstMatch(txt);
          if(secMatch!=null){
            sectionForRow[ri]=int.parse(secMatch.group(1)!);
            break;
          }
        }

        // Parse each cell as a potential course
        for(var ci=0;ci<texts.length;ci++){
          final txt=texts[ci];
          if(txt.isEmpty||txt=='&nbsp;')continue;
          // Skip pure time/section labels
          if(RegExp(r'^\s*第?\d+节\s*\d{2}:\d{2}').hasMatch(txt))continue;
          if(RegExp(r'^\s*(上午|下午|晚上|早晨)\s*$').hasMatch(txt))continue;

          final dow=colToDay[ci];
          if(dow==null||dow<1||dow>7)continue;

          final section=sectionForRow[ri]??_guessSection(ri,rows.length);
          if(section<1)continue;

          // Check if this text looks like a course
          if(_looksLikeCourseData(txt)){
            c.addAll(_parseCell(txt,dow,section));
          }
        }
      }

      if(c.isNotEmpty)return c;
    }
    return [];
  }

  int _guessSection(int rowIdx,int totalRows){
    // Rough estimate based on position
    if(totalRows<=8)return rowIdx+1;
    return (rowIdx%12)+1;
  }

  bool _looksLikeCourseData(String txt){
    if(txt.length<2||txt.length>200)return false;
    if(RegExp(r'^\s*(第?\d+节|节次|时间|星期|周次|上午|下午)\s*$').hasMatch(txt))return false;
    // Must contain Chinese characters (course names are in Chinese)
    if(!RegExp(r'[一-龥]').hasMatch(txt))return false;
    return true;
  }

  // ── Cell content parsing ──
  List<Course> _parseCell(String text,int dow,int section){
    final c=<Course>[];
    final blocks=text.split('---------------------');
    if(blocks.length==1)blocks.setAll(0,[text]);
    for(final block in blocks){
      if(block.trim().isEmpty)continue;
      final lines=block.split('\n').map((l)=>l.trim()).where((l)=>l.isNotEmpty).toList();
      if(lines.isEmpty)continue;
      final name=lines.first;
      String teacher='',loc='';List<int> weeks=[];int ss=section,ee=section+1;
      for(final line in lines){
        final wi=_parseWeekInfo(line);
        if(wi!=null){weeks=wi['weeks']??weeks;ss=wi['start']??ss;ee=wi['end']??ee;}
        if(line.contains('教师')||line.contains('老师'))teacher=line.replaceAll(RegExp(r'教师[：:]|老师[：:]|讲师[：:]'),'').trim();
        if(line.contains('地点')||line.contains('教室')||line.contains('场所'))loc=line.replaceAll(RegExp(r'地点[：:]|教室[：:]|场所[：:]'),'').trim();
      }
      c.add(Course(courseId:'${name}_${dow}_${ss}_$_ci',name:name,teacher:teacher,location:loc,dayOfWeek:dow,startSection:ss,endSection:ee,weeks:weeks.isNotEmpty?weeks:List.generate(16,(i)=>i+1),colorHex:_nc()));
    }
    return c;
  }

  // ── Text scan fallback ──
  List<Course> _parseByTextScan(String allText){
    final c=<Course>[];
    final lines=allText.split('\n').map((l)=>l.trim()).where((l)=>l.isNotEmpty).toList();
    for(var i=0;i<lines.length;i++){
      final line=lines[i];
      if(!_looksLikeCourseData(line))continue;
      String teacher='',loc='';int dow=0,ss=1,ee=2;
      List<int> weeks=List.generate(16,(idx)=>idx+1);
      for(var j=i;j<lines.length&&j<i+5;j++){
        final ctx=lines[j];
        if(ctx.contains('教师')||ctx.contains('老师'))teacher=_cleanLabel(ctx,['教师','老师','讲师']);
        if(ctx.contains('教室')||ctx.contains('地点')||ctx.contains('场所'))loc=_cleanLabel(ctx,['教室','地点','场所']);
        final wi=_parseWeekInfo(ctx);if(wi!=null){weeks=wi['weeks']??weeks;ss=wi['start']??ss;ee=wi['end']??ee;}
        for(var k=0;k<7;k++){final dk=['周一','周二','周三','周四','周五','周六','周日'];if(ctx.contains(dk[k]))dow=k+1;}
      }
      if(dow>0&&!c.any((x)=>x.name==line&&x.dayOfWeek==dow&&x.startSection==ss)){
        c.add(Course(courseId:'scan_${line}_$_ci',name:line,teacher:teacher,location:loc,dayOfWeek:dow,startSection:ss,endSection:ee,weeks:weeks,colorHex:_nc(),schoolSystem:'auto'));
      }
    }
    return c;
  }

  // ── Week/section info parsing ──
  Map<String,dynamic>? _parseWeekInfo(String t){
    int? s,e;List<int>? w;
    var m=RegExp(r'(\d+)\s*[-~–]\s*(\d+)\s*周').firstMatch(t);
    if(m!=null){s=int.tryParse(m.group(1)!);e=int.tryParse(m.group(2)!);w=List.generate(e!-s!+1,(i)=>s!+i);}
    m=RegExp(r'第\s*(\d+)\s*[-~–]\s*(\d+)\s*节').firstMatch(t);
    if(m!=null){s=int.tryParse(m.group(1)!)??s;e=int.tryParse(m.group(2)!)??e;}
    m=RegExp(r'第\s*(\d+)\s*[,，]\s*(\d+)\s*节').firstMatch(t);
    if(m!=null){if(s==null)s=int.tryParse(m.group(1)!);if(e==null)e=int.tryParse(m.group(2)!);}
    if(w!=null||s!=null||e!=null)return{'start':s,'end':e,'weeks':w};
    return null;
  }

  // ── Helpers ──
  int _mapDay(int col,int total){if(total>=8)return col;if(total==7)return col+1;return col.clamp(1,7);}
  String _cleanLabel(String t,List<String> labels){for(final l in labels){if(t.contains(l))return t.replaceAll(RegExp('$l[：: ]*'),'').trim();}return'';}
  String _nc(){final c=ColorUtils.getByIndex(_ci);_ci++;return'#${c.toARGB32().toRadixString(16).padLeft(8,'0').substring(2)}';}
}
