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
          GoRoute(path: home, builder: (_, __) => const HomeScreen()),
          GoRoute(path: search, builder: (_, __) => const SearchScreen()),
          GoRoute(path: recipe, builder: (_, __) => const RecipeScreen()),
          GoRoute(path: favorites, builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: profile, builder: (_, __) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: settings, builder: (_, __) => const SettingsScreen()),
      GoRoute(path: detail, builder: (_, __) => const DetailScreen()),
      GoRoute(
        path: notification,
        builder: (_, __) => const NotificationScreen(),
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
    if (path.startsWith(settings)) return 'Settings';
    if (path.startsWith(detail)) return 'Detail';
    if (path.startsWith(notification)) return 'Notifications';
    return 'Recipe App';
  }

  static String _subtitleFromLocation(String path) {
    if (path.startsWith(home)) return 'Chao mung ban quay tro lai';
    if (path.startsWith(search)) return 'Tim kiem nhanh nguyen lieu va mon an';
    if (path.startsWith(recipe)) return 'Tim thay 6 cong thuc phu hop';
    if (path.startsWith(favorites))
      return 'Tro chuyen va nhan goi y thong minh';
    if (path.startsWith(profile)) return 'Quan ly thong tin ca nhan cua ban';
    if (path.startsWith(settings)) return 'Tuy chinh ung dung theo nhu cau';
    if (path.startsWith(detail)) return 'Thong tin chi tiet mon an';
    if (path.startsWith(notification)) return 'Cap nhat thong bao moi nhat';
    return 'Ung dung nau an';
  }
}
