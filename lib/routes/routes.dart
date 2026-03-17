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
  static const String detailRecipeBase = '/detail-recipe';
  static const String detailRecipe = '/detail-recipe/:recipeId';
  static const String detailStepBase = '/detail-step';
  static const String detailStep = '/detail-step/:recipeId';
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
          GoRoute(path: home, builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: search,
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: recipe,
            builder: (context, state) => const RecipeScreen(),
          ),
          GoRoute(
            path: favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(path: detail, builder: (context, state) => const DetailScreen()),
      GoRoute(
        path: detailRecipe,
        builder: (context, GoRouterState state) {
          final String recipeId = state.pathParameters['recipeId'] ?? '';
          return DetailRecipeScreen(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: detailStep,
        builder: (context, GoRouterState state) {
          final String recipeId = state.pathParameters['recipeId'] ?? '';
          final int initialStep =
              int.tryParse(state.uri.queryParameters['step'] ?? '0') ?? 0;
          return DetailStepScreen(recipeId: recipeId, initialStep: initialStep);
        },
      ),
      GoRoute(
        path: notification,
        builder: (context, state) => const NotificationScreen(),
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
    if (path.startsWith(detailStepBase)) return 'Nấu từng bước';
    if (path.startsWith(notification)) return 'Notifications';
    return 'Recipe App';
  }

  static String _subtitleFromLocation(String path) {
    if (path.startsWith(home)) return 'Chào mừng bạn trở lại';
    if (path.startsWith(search)) return 'Tìm kiếm nhanh nguyên liệu và món ăn';
    if (path.startsWith(recipe)) return 'Tìm thấy 6 công thức phù hợp';
    if (path.startsWith(favorites)) {
      return 'Trò chuyện và nhận gợi ý thông minh';
    }
    if (path.startsWith(profile)) return 'Quản lý thông tin cá nhân của bạn';
    if (path.startsWith(settings)) return 'Tùy chỉnh ứng dụng theo nhu cầu';
    if (path.startsWith(detail)) return 'Thông tin chi tiết món ăn';
    if (path.startsWith(detailStepBase)) return 'Làm theo hướng dẫn mỗi bước';
    if (path.startsWith(notification)) return 'Cập nhật thông báo mới nhất';
    return 'Ứng dụng nấu ăn';
  }
}
