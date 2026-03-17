import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/screens.dart';
import '../widgets/widgets.dart';

class AppRoutes {
  static const String home = '/home';
  static const String search = '/search';
  static const String recipe = '/recipe';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String detail = '/detail';
  static const String notification = '/notification';
  static const String historyRecognize = '/history-recognize';

  static final GoRouter router = GoRouter(
    initialLocation: recipe,
    routes: <RouteBase>[
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          final int index = _indexFromLocation(state.uri.path);
          return Scaffold(
            appBar: AppHeaderBar(
              title: _titleFromLocation(state.uri.path),
              subtitle: _subtitleFromLocation(state.uri.path),
            ),
            body: child,
            bottomNavigationBar: AppBottomNavBar(currentIndex: index),
          );
        },
        routes: <RouteBase>[
          GoRoute(path: home, builder: (_, _) => const HomeScreen()),
          GoRoute(path: search, builder: (_, _) => const SearchScreen()),
          GoRoute(path: recipe, builder: (_, _) => const RecipeScreen()),
          GoRoute(path: favorites, builder: (_, _) => const FavoritesScreen()),
          GoRoute(path: profile, builder: (_, _) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: detail, builder: (_, _) => const DetailScreen()),
      GoRoute(
        path: historyRecognize,
        builder: (_, GoRouterState state) {
          final String tab = state.uri.queryParameters['tab'] ?? 'pantry';
          return HistoryRecognizeScreen(
            initialTab: tab == 'history'
                ? HistoryTab.history
                : HistoryTab.pantry,
          );
        },
      ),
      GoRoute(
        path: notification,
        builder: (_, _) => const NotificationScreen(),
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      );
    },
  );

  static int _indexFromLocation(String path) {
    if (path.startsWith(home)) return 0;
    if (path.startsWith(search)) return 1;
    if (path.startsWith(recipe)) return 2;
    if (path.startsWith(favorites)) return 3;
    if (path.startsWith(profile)) return 4;
    return 2;
  }

  static String _titleFromLocation(String path) {
    if (path.startsWith(home)) return 'Trang chủ';
    if (path.startsWith(search)) return 'Quét';
    if (path.startsWith(recipe)) return 'Công thức';
    if (path.startsWith(favorites)) return 'Chat AI';
    if (path.startsWith(profile)) return 'Hồ sơ';
    if (path.startsWith(settings)) return 'Cài đặt';
    if (path.startsWith(detail)) return 'Chi tiết';
    if (path.startsWith(notification)) return 'Thông báo';
    if (path.startsWith(historyRecognize)) return 'Nguyên liệu của tôi';
    return 'Recipe App';
  }

  static String _subtitleFromLocation(String path) {
    if (path.startsWith(home)) return 'Chào mừng bạn quay trở lại';
    if (path.startsWith(search)) return 'Tìm kiếm nhanh nguyên liệu và món ăn';
    if (path.startsWith(recipe)) return 'Khám phá công thức phù hợp';
    if (path.startsWith(favorites)) {
      return 'Trò chuyện và nhận gợi ý thông minh';
    }
    if (path.startsWith(profile)) return 'Quản lý thông tin cá nhân của bạn';
    if (path.startsWith(settings)) return 'Tùy chỉnh ứng dụng theo nhu cầu';
    if (path.startsWith(detail)) return 'Thông tin chi tiết món ăn';
    if (path.startsWith(notification)) return 'Cập nhật thông báo mới nhất';
    if (path.startsWith(historyRecognize)) return 'Quản lý kho và lịch sử quét';
    return 'Ứng dụng nấu ăn';
  }
}
