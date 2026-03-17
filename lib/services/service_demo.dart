import '../models/models.dart';
import 'ingredient_api_service.dart';
import 'recipe_api_service.dart';
import 'scan_api_service.dart';
import 'scan_local_storage_service.dart';
import 'dart:typed_data';

class ServiceDemo {
  static Future<List<IngredientItem>> getPopularIngredients({int limit = 8}) {
    return IngredientApiService.getPopularIngredients(limit: limit);
  }

  static Future<List<IngredientItem>> getRandomIngredients({
    int limit = 12,
    String? categoryId,
  }) {
    return IngredientApiService.getRandomIngredients(
      limit: limit,
      categoryId: categoryId,
    );
  }

  static Future<ScanResult> scanIngredients({required String userId}) {
    return ScanApiService.scanDemo(userId: userId);
  }

  static Future<ScanResult> scanImageBytes({
    required String userId,
    required Uint8List imageBytes,
    String fileName = 'capture.jpg',
  }) {
    return ScanApiService.scanImageBytes(
      userId: userId,
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }

  static Future<List<IngredientCategoryItem>> getCategories() {
    return IngredientApiService.getCategories();
  }

  static Future<List<IngredientItem>> getIngredientsByCategory({
    required String categoryId,
    int limit = 50,
  }) {
    return IngredientApiService.getIngredientsByCategory(
      categoryId: categoryId,
      limit: limit,
    );
  }

  static Future<List<RecipeItem>> getRandomRecipes({int limit = 4}) {
    return RecipeApiService.getRandomRecipes(limit: limit);
  }

  static Future<List<ScanHistoryItem>> getScanHistory() {
    return ScanLocalStorageService.getScanHistory();
  }
}
