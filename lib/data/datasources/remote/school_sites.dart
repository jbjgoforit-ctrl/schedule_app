import 'dart:convert';import 'package:shared_preferences/shared_preferences.dart';

class JwSystemTemplate {
  final String id;final String name;final String urlHint;final String loginPath;final List<String> schedulePaths;final List<String> captchaPaths;
  const JwSystemTemplate(this.id,this.name,this.urlHint,this.loginPath,this.schedulePaths,this.captchaPaths);
  static const List<JwSystemTemplate> all=[
    JwSystemTemplate('zhengfang','正方教务系统','http://jwxt.example.edu.cn','/default2.aspx',['/xskbcx.aspx','/xsgrkbcx.aspx','/kbcx.aspx'],['/CheckCode.aspx','/sys/ValidateCode.aspx']),
    JwSystemTemplate('urp','URP教务系统','http://urp.example.edu.cn','/loginAction.do',['/student/teachingPlan/courseTable','/courseTable.do'],['/captcha','/verifycode']),
    JwSystemTemplate('qiangzhi','强智教务系统','http://jwgl.example.edu.cn','/jwglxt/xtgl/login_slogin.html',['/jwglxt/kbcx/xskbcx_cxXskbcxIndex.html'],['/jwglxt/captcha']),
    JwSystemTemplate('new_gen','新一代教务系统','http://jwxt.example.edu.cn','/xtgl/login_slogin.html',['/kbcx/xskbcx_cxXskbcxIndex.html'],['/xtgl/captcha']),
    JwSystemTemplate('kingosoft','青果教务系统','http://jwc.example.edu.cn','/login.aspx',['/xsxx/kbcx.aspx'],['/checkcode.aspx']),
    JwSystemTemplate('shuwei','树维教务系统','http://jwxt.example.edu.cn','/student/login',['/student/courseTable','/student/schedule'],['/captcha']),
    JwSystemTemplate('custom','自定义/其他','https://jwxt.example.edu.cn','/login',['/schedule','/kbcx','/course'],['/captcha','/verifycode']),
  ];
}

class SchoolSite {
  final String name;final String url;final String? remark;final bool isCustom;final String systemType;
  const SchoolSite(this.name,this.url,[this.remark,this.isCustom=false,this.systemType='zhengfang']);
  Map<String,dynamic> toJson()=>{'name':name,'url':url,'systemType':systemType};
  factory SchoolSite.fromJson(Map<String,dynamic> j)=>SchoolSite(j['name']as String,j['url']as String,null,true,j['systemType']as String? ?? 'zhengfang');

  static const List<SchoolSite> all=[
    // === 正方教务系统 ===
    SchoolSite('清华大学','http://zhjw.cic.tsinghua.edu.cn',null,false,'zhengfang'),
    SchoolSite('北京大学','https://dean.pku.edu.cn',null,false,'zhengfang'),
    SchoolSite('浙江大学','http://jwbinfosys.zju.edu.cn',null,false,'zhengfang'),
    SchoolSite('复旦大学','http://jwfw.fudan.edu.cn',null,false,'zhengfang'),
    SchoolSite('上海交通大学','http://electsys.sjtu.edu.cn',null,false,'zhengfang'),
    SchoolSite('南京大学','http://jw.nju.edu.cn',null,false,'zhengfang'),
    SchoolSite('中国人民大学','http://jw.ruc.edu.cn',null,false,'zhengfang'),
    SchoolSite('武汉大学','http://bkjw.whu.edu.cn',null,false,'zhengfang'),
    SchoolSite('华中科技大学','http://jwc.hust.edu.cn',null,false,'zhengfang'),
    SchoolSite('中山大学','http://jwc.sysu.edu.cn',null,false,'zhengfang'),
    SchoolSite('四川大学','http://jwc.scu.edu.cn',null,false,'zhengfang'),
    SchoolSite('西安交通大学','http://jwc.xjtu.edu.cn',null,false,'zhengfang'),
    SchoolSite('哈尔滨工业大学','http://jwc.hit.edu.cn',null,false,'zhengfang'),
    SchoolSite('中国科学技术大学','http://mis.teach.ustc.edu.cn',null,false,'zhengfang'),
    // === URP教务系统 ===
    SchoolSite('北京航空航天大学','http://jiaowu.buaa.edu.cn',null,false,'urp'),
    SchoolSite('北京理工大学','http://jwc.bit.edu.cn',null,false,'urp'),
    SchoolSite('同济大学','http://jwc.tongji.edu.cn',null,false,'urp'),
    SchoolSite('南开大学','http://jwc.nankai.edu.cn',null,false,'urp'),
    SchoolSite('天津大学','http://jwc.tju.edu.cn',null,false,'urp'),
    SchoolSite('东南大学','http://jwc.seu.edu.cn',null,false,'urp'),
    SchoolSite('厦门大学','http://jwc.xmu.edu.cn',null,false,'urp'),
    SchoolSite('山东大学','http://www.jwc.sdu.edu.cn',null,false,'urp'),
    SchoolSite('中南大学','http://jwc.csu.edu.cn',null,false,'urp'),
    SchoolSite('电子科技大学','http://www.jwc.uestc.edu.cn',null,false,'urp'),
    SchoolSite('重庆大学','http://jwc.cqu.edu.cn',null,false,'urp'),
    SchoolSite('大连理工大学','http://teach.dlut.edu.cn',null,false,'urp'),
    // === 强智教务系统 ===
    SchoolSite('湖南大学','http://jwc.hnu.edu.cn',null,false,'qiangzhi'),
    SchoolSite('中国农业大学','http://jwc.cau.edu.cn',null,false,'qiangzhi'),
    SchoolSite('华南理工大学','http://jwc.scut.edu.cn',null,false,'qiangzhi'),
    SchoolSite('西北工业大学','http://jwc.nwpu.edu.cn',null,false,'qiangzhi'),
    // === 新一代教务系统 ===
    SchoolSite('北京师范大学','http://jwc.bnu.edu.cn',null,false,'new_gen'),
    SchoolSite('中国海洋大学','http://jwc.ouc.edu.cn',null,false,'new_gen'),
    SchoolSite('东北大学','http://www.jwc.neu.edu.cn',null,false,'new_gen'),
    SchoolSite('吉林大学','http://jwc.jlu.edu.cn',null,false,'new_gen'),
    SchoolSite('兰州大学','http://jwc.lzu.edu.cn',null,false,'new_gen'),
    SchoolSite('华东师范大学','http://www.jwc.ecnu.edu.cn',null,false,'new_gen'),
    // === 青果教务系统 ===
    SchoolSite('国防科技大学','http://jwc.nudt.edu.cn',null,false,'kingosoft'),
    SchoolSite('西北农林科技大学','http://jwc.nwafu.edu.cn',null,false,'kingosoft'),
    // === 树维教务系统 ===
    SchoolSite('中央民族大学','http://jwc.muc.edu.cn',null,false,'shuwei'),
  ];

  static Future<List<SchoolSite>> loadCustom()async{final p=await SharedPreferences.getInstance();final j=p.getString('csites2');if(j==null||j.isEmpty)return[];try{final l=jsonDecode(j)as List;return l.map((e)=>SchoolSite.fromJson(e)).toList();}catch(_){return[];}}
  static Future<void> addCustom(String name,String url,String systemType)async{final c=await loadCustom();c.removeWhere((s)=>s.url==url);c.insert(0,SchoolSite(name,url,null,true,systemType));final p=await SharedPreferences.getInstance();await p.setString('csites2',jsonEncode(c.map((s)=>s.toJson()).toList()));}
  static Future<void> removeCustom(String url)async{final c=await loadCustom();c.removeWhere((s)=>s.url==url);final p=await SharedPreferences.getInstance();await p.setString('csites2',jsonEncode(c.map((s)=>s.toJson()).toList()));}
  static Future<List<SchoolSite>> searchAsync(String q)async{final customs=await loadCustom();final allSites=[...customs,...all];if(q.isEmpty)return allSites;return allSites.where((s)=>s.name.contains(q)||s.url.toLowerCase().contains(q.toLowerCase())).toList();}
  static List<SchoolSite> bySystem(String type)=>all.where((s)=>s.systemType==type).toList();
}
