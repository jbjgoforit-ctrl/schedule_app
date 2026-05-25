import 'package:go_router/go_router.dart';
import '../../features/home/home_shell.dart';
import '../../features/import/presentation/import_screen.dart';
import '../../features/import/presentation/webview_import_screen.dart';
import '../../features/course/presentation/course_detail_screen.dart';
import '../../features/course/presentation/course_editor_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/profile/presentation/feedback_screen.dart';
import '../../features/skin_store/presentation/skin_store_screen.dart';
import '../../features/settings/presentation/update_screen.dart';

final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/home', name: 'home', builder: (c, s) => const HomeShell()),
    GoRoute(path: '/import', name: 'import', builder: (c, s) => const ImportScreen()),
    GoRoute(path: '/import/webview', name: 'import_webview', builder: (c, s) {
      final e = s.extra as Map<String, String>;
      return WebViewImportScreen(url: e['url']!, schoolName: e['name']!);
    }),
    GoRoute(path: '/course/add', name: 'course_add', builder: (c, s) {
      final e = s.extra as Map<String, int>?;
      return CourseEditorScreen(prefillDay: e?['day'], prefillSection: e?['section']);
    }),
    GoRoute(path: '/course/:id', name: 'course_detail', builder: (c, s) => CourseDetailScreen(courseId: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/course/:id/edit', name: 'course_edit', builder: (c, s) => CourseEditorScreen(editCourseId: int.parse(s.pathParameters['id']!))),
    GoRoute(path: '/settings', name: 'settings', builder: (c, s) => const SettingsScreen()),
    GoRoute(path: '/feedback', name: 'feedback', builder: (c, s) => const FeedbackScreen()),
    GoRoute(path: '/skin_store', name: 'skin_store', builder: (c, s) => const SkinStoreScreen()),
    GoRoute(path: '/update', name: 'update', builder: (c, s) => const UpdateScreen()),
  ],
);
