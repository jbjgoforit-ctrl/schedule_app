import 'dart:io';import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';import 'package:webview_flutter/webview_flutter.dart';import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'import_provider.dart';import '../../../core/constants/app_colors.dart';import '../../../core/constants/app_text_styles.dart';

class WebViewImportScreen extends ConsumerStatefulWidget{final String url;final String schoolName;const WebViewImportScreen({super.key,required this.url,required this.schoolName});@override ConsumerState<WebViewImportScreen> createState()=>_S();}
class _S extends ConsumerState<WebViewImportScreen>{WebViewController? _ctrl;bool _loading=true;int _attempts=0;bool _importing=false;
  @override void initState(){super.initState();_init();}
  void _init(){
    _ctrl=WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    if(Platform.isAndroid){
      final ac=_ctrl!.platform as AndroidWebViewController;
      ac.setMediaPlaybackRequiresUserGesture(false);
    }
    _ctrl!..setNavigationDelegate(NavigationDelegate(
        onPageStarted:(_){if(mounted)setState(()=>_loading=true);},
        onPageFinished:(_){if(mounted)setState(()=>_loading=false);},
        onWebResourceError:(e){},
      ))
      ..loadRequest(Uri.parse(widget.url));
    Future.delayed(const Duration(seconds:10),(){if(mounted)setState(()=>_loading=false);});
  }
  @override Widget build(BuildContext c){if(_ctrl==null)return Scaffold(appBar:AppBar(title:Text(widget.schoolName)),body:const Center(child:CircularProgressIndicator()));return Scaffold(appBar:AppBar(title:Text(widget.schoolName),actions:[IconButton(icon:const Icon(Icons.refresh),tooltip:'refresh',onPressed:()=>_ctrl!.reload())]),body:Column(children:[_banner(),if(_loading)const LinearProgressIndicator(),Expanded(child:WebViewWidget(controller:_ctrl!))]),floatingActionButton:_fab());}
  Widget _banner(){final kw=Container(width:double.infinity,padding:const EdgeInsets.all(12),decoration:const BoxDecoration(color:Color(0xFFFFF3E0)),child:Row(children:[const Icon(Icons.info_outline,size:16,color:Color(0xFFE65100)),const SizedBox(width:6),Expanded(child:Text('登录后导航到个人课表页面，点右下角导入',style:TextStyle(fontSize:12,color:Color(0xFF795548))))]));if(_attempts==0)return kw;return Column(children:[kw,Container(padding:const EdgeInsets.all(8),color:Colors.red.shade50,child:Row(children:[const Icon(Icons.warning_amber,size:16,color:Colors.red),const SizedBox(width:6),Expanded(child:Text(_attempts==1?'未检测到课表，请确认已登录到个人课表页面':'仍无法识别，试试切换到周课表视图',style:const TextStyle(fontSize:12,color:Colors.red)))])),]);}
  Widget _fab(){return Column(mainAxisSize:MainAxisSize.min,children:[Container(margin:const EdgeInsets.only(bottom:2),padding:const EdgeInsets.symmetric(horizontal:14,vertical:6),decoration:BoxDecoration(color:Colors.black87,borderRadius:BorderRadius.circular(20)),child:Text(_importing?'capturing...':'点击导入课表',style:const TextStyle(color:Colors.white,fontSize:12))),FloatingActionButton.extended(onPressed:_importing?null:_capture,backgroundColor:AppColors.primary,icon:_importing?const SizedBox(width:18,height:18,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):const Icon(Icons.file_download),label:Text(_importing?'解析中...':'导入'))]);}
  Future<void> _capture()async{if(_ctrl==null)return;setState(()=>_importing=true);try{await Future.delayed(const Duration(seconds:3));final html=await _ctrl!.runJavaScriptReturningResult('document.documentElement.outerHTML');String htmlStr='';if(html is String)htmlStr=_decodeJSString(html);if(htmlStr.isEmpty){_fail('页面为空，请先登录并导航到课表');return;}ref.read(importStateProvider.notifier).importFromHtml(htmlStr);await Future.delayed(const Duration(milliseconds:500));final state=ref.read(importStateProvider);if(state.errorMessage!=null){_fail(state.errorMessage!);return;}if(state.previewCourses.isNotEmpty){setState((){_importing=false;_attempts=0;});Navigator.pop(context,true);return;}_fail('未找到课程数据，请确认已登录并导航到课表页面');}catch(e){_fail('Error: $e');}}
  String _decodeJSString(String s){try{return s.replaceAllMapped(RegExp(r'\\u([0-9a-fA-F]{4})'),(m)=>String.fromCharCode(int.parse(m.group(1)!,radix:16))).replaceAll('\\n','\n').replaceAll('\\t','\t').replaceAll('\\"','"').replaceAll("\\'","'");}catch(_){return s;}}
  void _fail(String msg){setState((){_importing=false;_attempts++;});if(mounted){showDialog(context:context,builder:(c)=>AlertDialog(title:Text('导入失败 ($_attempts)'),content:SingleChildScrollView(child:Text(msg,style:const TextStyle(fontSize:13))),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('OK'))]));}}
}
