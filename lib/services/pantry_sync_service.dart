import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/pantry_item.dart';
import 'pantry_api_service.dart';

class PantrySaveOutcome {
  const PantrySaveOutcome({required this.queued, required this.message});

  final bool queued;
  final String message;
}

class PantryDeleteOutcome {
  const PantryDeleteOutcome({required this.queued, required this.message});

  final bool queued;
  final String message;
}

class PantrySyncService {
  static const String _queueKey = 'pantry_sync_queue_v1';
  static const String _cacheKey = 'pantry_cache_items_v1';

  static Future<List<PantryItem>> getPantryWithSync({
    required String userId,
  }) async {
    autoSync(userId: userId);

    try {
      final List<PantryItem> remote = await PantryApiService.getPantry(
        userId: userId,
      );
      await _saveCachedPantry(remote);
      return remote;
    } catch (_) {
      return _getCachedPantry();
    }
  }

  static Future<PantrySaveOutcome> saveIngredientTwoWay({
    required String userId,
    required String ingredientId,
    required String ingredientName,
    required String ingredientIcon,
    String quantity = '1',
  }) async {
    try {
      await PantryApiService.saveIngredient(
        userId: userId,
        ingredientId: ingredientId,
        quantity: quantity,
      );
      await autoSync(userId: userId);
      return const PantrySaveOutcome(
        queued: false,
        message: 'Đã lưu vào kho trên máy chủ.',
      );
    } catch (_) {
      final String localPantryItemId = _newLocalId();
      await _enqueue(<String, dynamic>{
        'id': _newQueueId(),
        'type': 'add',
        'user_id': userId,
        'ingredient_id': ingredientId,
        'ingredient_name': ingredientName,
        'ingredient_icon': ingredientIcon,
        'quantity': quantity,
        'local_pantry_item_id': localPantryItemId,
      });

      final List<PantryItem> cache = await _getCachedPantry();
      cache.insert(
        0,
        PantryItem(
          id: localPantryItemId,
          userId: userId,
          ingredientId: ingredientId,
          quantity: quantity,
          ingredientName: ingredientName,
          ingredientIcon: ingredientIcon,
        ),
      );
      await _saveCachedPantry(cache);

      return const PantrySaveOutcome(
        queued: true,
        message: 'Đang ngoại tuyến, đã thêm vào hàng đợi đồng bộ.',
      );
    }
  }

  static Future<PantryDeleteOutcome> deletePantryItemTwoWay({
    required String userId,
    required PantryItem item,
  }) async {
    if (item.id.startsWith('local-')) {
      await _removeQueuedAddByLocalId(item.id);
      final List<PantryItem> cache = await _getCachedPantry();
      cache.removeWhere((PantryItem pantryItem) => pantryItem.id == item.id);
      await _saveCachedPantry(cache);
      return const PantryDeleteOutcome(
        queued: true,
        message: 'Đã xóa mục tạm trong bộ nhớ cục bộ.',
      );
    }

    try {
      await PantryApiService.deletePantryItem(
        userId: userId,
        pantryItemId: item.id,
      );
      await autoSync(userId: userId);
      return const PantryDeleteOutcome(
        queued: false,
        message: 'Đã xóa khỏi máy chủ.',
      );
    } catch (_) {
      await _enqueue(<String, dynamic>{
        'id': _newQueueId(),
        'type': 'delete',
        'user_id': userId,
        'pantry_item_id': item.id,
      });
      final List<PantryItem> cache = await _getCachedPantry();
      cache.removeWhere((PantryItem pantryItem) => pantryItem.id == item.id);
      await _saveCachedPantry(cache);
      return const PantryDeleteOutcome(
        queued: true,
        message: 'Đang ngoại tuyến, đã đưa vào hàng đợi đồng bộ xóa.',
      );
    }
  }

  static Future<void> autoSync({required String userId}) async {
    final List<Map<String, dynamic>> queue = await _getQueue();
    if (queue.isEmpty) {
      return;
    }

    final List<Map<String, dynamic>> remain = <Map<String, dynamic>>[];
    bool hasSuccess = false;

    for (final Map<String, dynamic> action in queue) {
      final String type = (action['type'] ?? '').toString();
      final String actionUserId = (action['user_id'] ?? '').toString();
      if (actionUserId != userId) {
        remain.add(action);
        continue;
      }

      try {
        if (type == 'add') {
          await PantryApiService.saveIngredient(
            userId: actionUserId,
            ingredientId: (action['ingredient_id'] ?? '').toString(),
            quantity: (action['quantity'] ?? '1').toString(),
          );
          hasSuccess = true;
          continue;
        }

        if (type == 'delete') {
          await PantryApiService.deletePantryItem(
            userId: actionUserId,
            pantryItemId: (action['pantry_item_id'] ?? '').toString(),
          );
          hasSuccess = true;
          continue;
        }

        remain.add(action);
      } catch (_) {
        remain.add(action);
      }
    }

    await _saveQueue(remain);

    if (hasSuccess) {
      try {
        final List<PantryItem> remote = await PantryApiService.getPantry(
          userId: userId,
        );
        await _saveCachedPantry(remote);
      } catch (_) {
        // Ignore refresh errors to keep queue state stable.
      }
    }
  }

  static Future<int> getPendingQueueCount() async {
    final List<Map<String, dynamic>> queue = await _getQueue();
    return queue.length;
  }

  static Future<List<Map<String, dynamic>>> _getQueue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_queueKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      await prefs.remove(_queueKey);
      return <Map<String, dynamic>>[];
    }

    if (decoded is! List<dynamic>) {
      return <Map<String, dynamic>>[];
    }

    return decoded.whereType<Map<String, dynamic>>().toList();
  }

  static Future<void> _saveQueue(List<Map<String, dynamic>> queue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queueKey, jsonEncode(queue));
  }

  static Future<void> _enqueue(Map<String, dynamic> action) async {
    final List<Map<String, dynamic>> queue = await _getQueue();
    queue.add(action);
    await _saveQueue(queue);
  }

  static Future<void> _removeQueuedAddByLocalId(
    String localPantryItemId,
  ) async {
    final List<Map<String, dynamic>> queue = await _getQueue();
    queue.removeWhere(
      (Map<String, dynamic> action) =>
          (action['type'] ?? '').toString() == 'add' &&
          (action['local_pantry_item_id'] ?? '').toString() ==
              localPantryItemId,
    );
    await _saveQueue(queue);
  }

  static Future<List<PantryItem>> _getCachedPantry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return <PantryItem>[];
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      await prefs.remove(_cacheKey);
      return <PantryItem>[];
    }

    if (decoded is! List<dynamic>) {
      return <PantryItem>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PantryItem.fromCacheJson)
        .toList();
  }

  static Future<void> _saveCachedPantry(List<PantryItem> items) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(items.map((PantryItem item) => item.toCacheJson()).toList()),
    );
  }

  static String _newQueueId() {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final int random = Random().nextInt(999999);
    return 'queue-$millis-$random';
  }

  static String _newLocalId() {
    final int millis = DateTime.now().millisecondsSinceEpoch;
    final int random = Random().nextInt(999999);
    return 'local-$millis-$random';
  }
}
