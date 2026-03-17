class ScanDetection {
  const ScanDetection({
    required this.detectedName,
    required this.confidence,
    required this.matched,
    this.ingredientId,
    this.ingredientName,
    this.ingredientIcon,
    this.ingredientImageUrl,
    this.ingredientCategoryName,
  });

  final String detectedName;
  final double confidence;
  final bool matched;
  final String? ingredientId;
  final String? ingredientName;
  final String? ingredientIcon;
  final String? ingredientImageUrl;
  final String? ingredientCategoryName;

  factory ScanDetection.fromJson(Map<String, dynamic> json) {
    final dynamic confidenceRaw = json['confidence'];
    final double normalizedConfidence = confidenceRaw is num
        ? confidenceRaw.toDouble()
        : double.tryParse((confidenceRaw ?? '').toString()) ?? 0.0;

    final Map<String, dynamic>? ingredient =
        json['ingredient'] is Map<String, dynamic>
        ? json['ingredient'] as Map<String, dynamic>
        : null;
    final Map<String, dynamic>? category =
        ingredient != null && ingredient['category'] is Map<String, dynamic>
        ? ingredient['category'] as Map<String, dynamic>
        : null;

    return ScanDetection(
      detectedName: (json['detected_name'] ?? '').toString(),
      confidence: normalizedConfidence,
      matched: json['matched'] == true,
      ingredientId: ingredient == null
          ? null
          : (ingredient['id'] ?? '').toString(),
      ingredientName: ingredient == null
          ? null
          : (ingredient['name'] ?? '').toString(),
      ingredientIcon: ingredient == null
          ? null
          : (ingredient['icon'] ?? '🥬').toString(),
      ingredientImageUrl: ingredient == null
          ? null
          : (ingredient['image_url'] ?? '').toString(),
      ingredientCategoryName: category == null
          ? null
          : (category['name'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'detected_name': detectedName,
      'confidence': confidence,
      'matched': matched,
      'ingredient': <String, dynamic>{
        'id': ingredientId,
        'name': ingredientName,
        'icon': ingredientIcon,
        'image_url': ingredientImageUrl,
        'category': <String, dynamic>{'name': ingredientCategoryName},
      },
    };
  }
}

class ScanResult {
  const ScanResult({required this.scanId, required this.items});

  final String scanId;
  final List<ScanDetection> items;

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        (json['ingredients'] as List<dynamic>?) ?? <dynamic>[];
    return ScanResult(
      scanId: (json['id'] ?? '').toString(),
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(ScanDetection.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': scanId,
      'ingredients': items.map((ScanDetection item) => item.toJson()).toList(),
    };
  }
}
