import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_history_item.dart';
import '../models/scan_result.dart';

class ScanLocalStorageService {
  static const String _scanHistoryKey = 'scan_history_items_v1';

  static Future<void> saveScanResult(ScanResult result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<ScanHistoryItem> existing = await getScanHistory();

    final ScanHistoryItem newItem = ScanHistoryItem(
      scanId: result.scanId,
      createdAt: DateTime.now(),
      items: result.items,
    );

    final List<ScanHistoryItem> merged = <ScanHistoryItem>[
      newItem,
      ...existing.where((ScanHistoryItem item) => item.scanId != result.scanId),
    ];

    final List<ScanHistoryItem> trimmed = merged.take(30).toList();

    await prefs.setString(
      _scanHistoryKey,
      jsonEncode(trimmed.map((ScanHistoryItem item) => item.toJson()).toList()),
    );
  }

  static Future<List<ScanHistoryItem>> getScanHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_scanHistoryKey);
    if (raw == null || raw.isEmpty) {
      return <ScanHistoryItem>[];
    }

    final dynamic decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      return <ScanHistoryItem>[];
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ScanHistoryItem.fromJson)
        .toList();
  }

  static Future<int> getHistoryCount() async {
    final List<ScanHistoryItem> items = await getScanHistory();
    return items.length;
  }
}
