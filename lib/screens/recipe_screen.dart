import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../routes/routes.dart';
import '../services/services.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  final RecipeService _recipeService = const RecipeService();
  final TextEditingController _searchController = TextEditingController();

  final List<Recipe> _recipes = <Recipe>[];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  bool _hasNextPage = true;

  String _selectedFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    _loadRecipes(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildSearchBox(),
          const SizedBox(height: 16),
          _buildFilterButtons(),
          const SizedBox(height: 20),
          _buildRecipeList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _loadRecipes(reset: true),
        decoration: InputDecoration(
          hintText: 'Tim mon an (vd: Spaghetti, Pho...)',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              if (_searchController.text.isEmpty) return;
              _searchController.clear();
              _loadRecipes(reset: true);
            },
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF22C55E)),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButtons() {
    final List<String> filters = <String>[
      'Tất cả',
      'Dễ',
      'Trung bình',
      'Nổi bật',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final filter = filters[index];
            final bool isSelected = _selectedFilter == filter;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  filter,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                backgroundColor: isSelected
                    ? const Color(0xFF22C55E)
                    : Colors.white,
                side: isSelected
                    ? BorderSide.none
                    : const BorderSide(color: Color(0xFFE5E7EB)),
                onSelected: (selected) {
                  if (!selected) return;
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _loadRecipes(reset: true);
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRecipeList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _errorMessage!,
                style: GoogleFonts.inter(color: const Color(0xFF991B1B)),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _loadRecipes(reset: true),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_recipes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            'Không tìm thấy công thức phù hợp.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          ...List<Widget>.generate(_recipes.length, (int index) {
            final Recipe recipe = _recipes[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == _recipes.length - 1 ? 0 : 16,
              ),
              child: _buildRecipeCard(recipe: recipe),
            );
          }),
          const SizedBox(height: 16),
          if (_hasNextPage)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isLoadingMore ? null : _loadMore,
                child: _isLoadingMore
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Tải thêm công thức'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard({required Recipe recipe}) {
    final String image = _resolveImageUrl(recipe.imageUrl);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        if (recipe.id.isEmpty) return;
        context.push(
          '${AppRoutes.detailRecipeBase}/${Uri.encodeComponent(recipe.id)}',
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildRecipeImage(image),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.speed,
                          size: 12,
                          color: Color(0xFF1F2937),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFFFCD34D),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recipe.rating?.toStringAsFixed(1) ?? '-',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 16,
                              color: Color(0xFF6B7280),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.cookTimeMinutes} phút',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (recipe.description.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        recipe.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF08A).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.restaurant,
                          size: 14,
                          color: Color(0xFFCA8A04),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          recipe.isFeatured ? 'Món nổi bật' : 'Xem công thức',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFFCA8A04),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _resolveImageUrl(String rawUrl) {
    final String trimmed = rawUrl.trim();
    if (trimmed.isEmpty) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200';
    }

    final Uri? uri = Uri.tryParse(trimmed);
    final bool validHttpUrl =
        uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');

    if (!validHttpUrl) {
      return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=1200';
    }

    return trimmed;
  }

  Widget _buildRecipeImage(String imageUrl) {
    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) {
              return child;
            }

            return Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
            );
          },
    );
  }

  Future<void> _loadRecipes({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPage = 1;
        _hasNextPage = true;
      });
    }

    try {
      final RecipePage page = await _recipeService.fetchRecipes(
        page: 1,
        perPage: 10,
        search: _searchController.text,
        difficulty: _mapDifficultyFilter(_selectedFilter),
        isFeatured: _selectedFilter == 'Nổi bật' ? true : null,
      );

      if (!mounted) return;
      setState(() {
        _recipes
          ..clear()
          ..addAll(page.items);
        _currentPage = page.page;
        _hasNextPage = page.hasNextPage;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Không thể tải danh sách công thức. Kiểm tra API_BASE_URL và thử lại.';
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasNextPage) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final int nextPage = _currentPage + 1;
      final RecipePage page = await _recipeService.fetchRecipes(
        page: nextPage,
        perPage: 10,
        search: _searchController.text,
        difficulty: _mapDifficultyFilter(_selectedFilter),
        isFeatured: _selectedFilter == 'Nổi bật' ? true : null,
      );

      if (!mounted) return;
      setState(() {
        _recipes.addAll(page.items);
        _currentPage = page.page;
        _hasNextPage = page.hasNextPage;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  String? _mapDifficultyFilter(String filterLabel) {
    switch (filterLabel) {
      case 'Dễ':
        return 'Easy';
      case 'Trung bình':
        return 'Medium';
      default:
        return null;
    }
  }
}
