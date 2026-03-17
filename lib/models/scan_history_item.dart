import 'scan_result.dart';

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.scanId,
    required this.createdAt,
    required this.items,
  });

  final String scanId;
  final DateTime createdAt;
  final List<ScanDetection> items;

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['items'] as List<dynamic>?) ?? <dynamic>[];

    return ScanHistoryItem(
      scanId: (json['scan_id'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.now(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ScanDetection.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'scan_id': scanId,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((ScanDetection item) => item.toJson()).toList(),
    };
  }
}
