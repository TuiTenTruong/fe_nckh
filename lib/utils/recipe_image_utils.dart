class RecipeImageUtils {
  static const String _defaultImageUrl =
      'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200';

  static String resolveRecipeImageUrl({
    required String rawUrl,
    required String recipeName,
  }) {
    final String trimmed = rawUrl.trim();
    if (_isLikelyImageUrl(trimmed)) {
      return trimmed;
    }

    final String generated = _buildNameBasedImageUrl(recipeName);
    return generated.isEmpty ? _defaultImageUrl : generated;
  }

  static bool _isLikelyImageUrl(String url) {
    if (url.isEmpty) return false;

    final Uri? uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    final String host = uri.host.toLowerCase();
    // source.unsplash.com often redirects to non-image content on some devices.
    if (host.contains('source.unsplash.com')) {
      return false;
    }

    if (host.contains('images.unsplash.com') ||
        host.contains('picsum.photos') ||
        host.contains('dummyimage.com')) {
      return true;
    }

    final String path = uri.path.toLowerCase();
    const List<String> imageExt = <String>[
      '.jpg',
      '.jpeg',
      '.png',
      '.webp',
      '.gif',
      '.bmp',
      '.avif',
    ];

    return imageExt.any(path.endsWith);
  }

  static String _buildNameBasedImageUrl(String recipeName) {
    final String normalized = recipeName.trim();
    if (normalized.isEmpty) {
      return _defaultImageUrl;
    }

    // Stable generated image URL based on recipe name to avoid decoder issues.
    final String text = Uri.encodeComponent(normalized);
    return 'https://dummyimage.com/1200x800/16a34a/ffffff.png&text=$text';
  }
}
