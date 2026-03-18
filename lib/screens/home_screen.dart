import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/models.dart';
import '../routes/routes.dart';
import '../services/services.dart';
import '../utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  String? _ingredientError;

  List<IngredientItem> _popularIngredients = const <IngredientItem>[];
  List<RecipeItem> _featuredRecipes = const <RecipeItem>[];

  void _openHomeSearch() {
    if (_loading) return;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _HomeSearchSheet(
          ingredients: _popularIngredients,
          recipes: _featuredRecipes,
          onTapIngredient: (IngredientItem item) {
            Navigator.of(context).pop();
            this.context.go(
              '/recipe?ingredient=${Uri.encodeComponent(item.name)}',
            );
          },
          onTapRecipe: (RecipeItem recipe) {
            Navigator.of(context).pop();
            this.context.go(
              '${AppRoutes.detailRecipeBase}/${Uri.encodeComponent(recipe.id)}',
            );
          },
        );
      },
    );
  }

  void _goRecipeByIngredient(IngredientItem item) {
    context.go('/recipe?ingredient=${Uri.encodeComponent(item.name)}');
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _loading = true;
      _ingredientError = null;
    });

    try {
      debugPrint('[Home] Loading data from ${ApiConfig.baseUrl}');
      final List<dynamic> results =
          await Future.wait<dynamic>(<Future<dynamic>>[
            ServiceDemo.getRandomIngredients(limit: 12),
            ServiceDemo.getRandomRecipes(limit: 4),
          ]);

      final List<IngredientItem> items = results[0] as List<IngredientItem>;
      final List<RecipeItem> recipes = results[1] as List<RecipeItem>;

      debugPrint(
        '[Home] API success: ingredients=${items.length}, recipes=${recipes.length}',
      );

      if (!mounted) return;
      setState(() {
        _popularIngredients = items;
        _featuredRecipes = recipes;
        _loading = false;
      });
    } catch (e) {
      debugPrint('[Home] API failed: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _ingredientError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFF1FFF5), Colors.white],
        ),
      ),
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadHomeData,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
            children: <Widget>[
              Text(
                'Xin chào! 👋',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1F2937),
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hôm nay bạn muốn nấu gì?',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              _SearchBox(onTap: _openHomeSearch),
              const SizedBox(height: 22),
              _ScanCtaCard(onOpenCamera: () => context.go('/search')),
              const SizedBox(height: 26),
              _SectionTitle(
                title: 'Nguyên liệu',
                trailingText: 'Tải lại',
                onTrailingTap: _loadHomeData,
              ),
              const SizedBox(height: 14),
              _buildIngredientsSection(),
              const SizedBox(height: 28),
              _SectionTitle(
                title: 'Gợi ý hôm nay',
                trailingText: 'Xem thêm',
                onTrailingTap: () => context.go('/recipe'),
              ),
              const SizedBox(height: 14),
              if (_loading)
                ...List<Widget>.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: _RecipeSkeletonCard(),
                  ),
                )
              else
                ..._featuredRecipes.map(
                  (RecipeItem recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _RecipeCard(
                      recipe: recipe,
                      onTap: () => context.go(
                        '${AppRoutes.detailRecipeBase}/${Uri.encodeComponent(recipe.id)}',
                      ),
                    ),
                  ),
                ),
              if (!_loading && _featuredRecipes.isEmpty)
                _EmptyHint(message: 'Chưa có công thức nổi bật từ hệ thống.'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsSection() {
    if (_loading) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (BuildContext context, int index) =>
            const _IngredientSkeletonCard(),
      );
    }

    if (_ingredientError != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          border: Border.all(color: const Color(0xFFFECACA)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Không tải được danh sách nguyên liệu.',
              style: GoogleFonts.inter(
                color: const Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _ingredientError!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: const Color(0xFFB91C1C),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    final List<IngredientItem> items = _popularIngredients;
    if (items.isEmpty) {
      return const _EmptyHint(message: 'Chưa có nguyên liệu từ hệ thống.');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (_, int index) => _IngredientCard(
        item: items[index],
        onTap: () => _goRecipeByIngredient(items[index]),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 10),
            Text(
              'Tìm món ăn hoặc nguyên liệu...',
              style: GoogleFonts.inter(
                color: const Color(0xFF9CA3AF),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanCtaCard extends StatelessWidget {
  const _ScanCtaCard({required this.onOpenCamera});

  final VoidCallback onOpenCamera;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF22C55E), Color(0xFF0E9F44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x3322C55E),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Quét nguyên liệu của bạn',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mở camera, gửi ảnh lên backend để nhận dạng nguyên liệu.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF16A34A),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                'Mở trang quét',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.trailingText,
    required this.onTrailingTap,
  });

  final String title;
  final String trailingText;
  final VoidCallback onTrailingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          title,
          style: GoogleFonts.inter(
            color: const Color(0xFF111827),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onTrailingTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              trailingText,
              style: GoogleFonts.inter(
                color: const Color(0xFF16A34A),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({required this.item, required this.onTap});

  final IngredientItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(item.icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF374151),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSearchSheet extends StatefulWidget {
  const _HomeSearchSheet({
    required this.ingredients,
    required this.recipes,
    required this.onTapIngredient,
    required this.onTapRecipe,
  });

  final List<IngredientItem> ingredients;
  final List<RecipeItem> recipes;
  final void Function(IngredientItem) onTapIngredient;
  final void Function(RecipeItem) onTapRecipe;

  @override
  State<_HomeSearchSheet> createState() => _HomeSearchSheetState();
}

class _HomeSearchSheetState extends State<_HomeSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String q = _query.trim().toLowerCase();
    final List<IngredientItem> ingredientResults = q.isEmpty
        ? widget.ingredients
        : widget.ingredients
              .where(
                (IngredientItem item) => item.name.toLowerCase().contains(q),
              )
              .toList();
    final List<RecipeItem> recipeResults = q.isEmpty
        ? widget.recipes
        : widget.recipes
              .where((RecipeItem item) => item.name.toLowerCase().contains(q))
              .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.92,
      builder: (_, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: <Widget>[
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                onChanged: (String value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Tìm nguyên liệu hoặc món ăn...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Nguyên liệu',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              if (ingredientResults.isEmpty)
                Text(
                  'Không có nguyên liệu phù hợp.',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                )
              else
                ...ingredientResults.map((IngredientItem item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      item.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(item.name),
                    subtitle: const Text('Xem công thức theo nguyên liệu này'),
                    onTap: () => widget.onTapIngredient(item),
                  );
                }),
              const SizedBox(height: 10),
              Text(
                'Món ăn',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              if (recipeResults.isEmpty)
                Text(
                  'Không có món ăn phù hợp.',
                  style: GoogleFonts.inter(color: const Color(0xFF64748B)),
                )
              else
                ...recipeResults.map((RecipeItem item) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.restaurant_menu),
                    title: Text(item.name),
                    subtitle: Text(
                      '${item.cookTimeMinutes} phút • ${item.difficulty}',
                    ),
                    onTap: () => widget.onTapRecipe(item),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final RecipeItem recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = RecipeImageUtils.resolveRecipeImageUrl(
      rawUrl: recipe.imageUrl,
      recipeName: recipe.name,
    );

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? st) {
                            return SvgPicture.asset(
                              'assets/svg/recipe_1.svg',
                              width: 58,
                              height: 58,
                              fit: BoxFit.cover,
                            );
                          },
                    )
                  : SvgPicture.asset(
                      'assets/svg/recipe_1.svg',
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
            ),
            title: Text(
              recipe.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${recipe.cookTimeMinutes} phút • ${recipe.difficulty}',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF3),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                recipe.isFeatured ? 'Nổi bật' : 'Đề xuất',
                style: GoogleFonts.inter(
                  color: const Color(0xFF15803D),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
      ),
    );
  }
}

class _IngredientSkeletonCard extends StatelessWidget {
  const _IngredientSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const _PulseSkeleton(borderRadius: 16, child: SizedBox.expand());
  }
}

class _RecipeSkeletonCard extends StatelessWidget {
  const _RecipeSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return const _PulseSkeleton(
      borderRadius: 16,
      child: SizedBox(height: 84, width: double.infinity),
    );
  }
}

class _PulseSkeleton extends StatefulWidget {
  const _PulseSkeleton({required this.child, this.borderRadius = 12});

  final Widget child;
  final double borderRadius;

  @override
  State<_PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<_PulseSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.45,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? _) {
        return Opacity(
          opacity: _controller.value,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
