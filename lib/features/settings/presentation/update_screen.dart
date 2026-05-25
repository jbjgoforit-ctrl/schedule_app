import 'package:flutter/material.dart';
import '../../../core/services/update_service.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});
  @override State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  bool _checking = true;
  UpdateInfo? _info;
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  @override void initState() {super.initState();_check();}
  Future<void> _check() async {
    setState(() {_checking = true;_error = null;_info = null;});
    try {
      final info = await UpdateService.checkUpdate();
      setState(() {_info = info;_checking = false;});
    } catch (e) {
      setState(() {_error = '网络连接失败，请检查网络后重试';_checking = false;});
    }
  }

  @override Widget build(BuildContext c) {
    return Scaffold(
      appBar: AppBar(title: const Text('检查更新')),
      body: Center(child: _checking ? const Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text('正在检查...')]) : _error != null ? _buildError() : _info == null ? _buildLatest() : _buildUpdate()),
    );
  }

  Widget _buildLatest() {
    return Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle, size: 64, color: Colors.green), const SizedBox(height: 16), const Text('已是最新版本', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('版本 1.0.0'), const SizedBox(height: 24), OutlinedButton(onPressed: _check, child: const Text('重新检查'))]);
  }

  Widget _buildError() {
    return Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 64, color: Colors.red), const SizedBox(height: 16), Text(_error!, style: const TextStyle(fontSize: 16)), const SizedBox(height: 24), OutlinedButton(onPressed: _check, child: const Text('重试'))]);
  }

  Widget _buildUpdate() {
    return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.system_update, size: 64, color: Colors.blue),
      const SizedBox(height: 16),
      const Text('发现新版本', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('版本 ${_info!.version}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: Text(_info!.changelog, style: const TextStyle(fontSize: 14))),
      const SizedBox(height: 24),
      if (_downloading) ...[
        LinearProgressIndicator(value: _progress),
        const SizedBox(height: 8),
        Text('下载中 ${(_progress * 100).toStringAsFixed(0)}%'),
      ] else
        FilledButton.icon(icon: const Icon(Icons.download), label: const Text('立即更新'), onPressed: _downloadAndInstall),
    ]));
  }

  Future<void> _downloadAndInstall() async {
    if (_info == null) return;
    setState(() {_downloading = true;_progress = 0;});
    final path = await UpdateService.downloadApk(_info!.url, onProgress: (p) {if (mounted) setState(() => _progress = p);});
    if (path != null && mounted) {
      setState(() => _downloading = false);
      await UpdateService.installApk(path);
    } else if (mounted) {
      setState(() {_downloading = false;_error = '下载失败，请重试';});
    }
  }
}
