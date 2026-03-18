import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../routes/routes.dart';
import '../services/services.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class DetailRecipeScreen extends StatefulWidget {
  const DetailRecipeScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  State<DetailRecipeScreen> createState() => _DetailRecipeScreenState();
}

class _DetailRecipeScreenState extends State<DetailRecipeScreen> {
  final RecipeService _service = const RecipeService();

  bool _isLoading = true;
  String? _error;
  RecipeDetail? _detail;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final RecipeDetail detail = await _service.fetchRecipeDetail(
        widget.recipeId,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được chi tiết công thức: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: AppBottomNavBar(currentIndex: 2),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: const Color(0xFF991B1B)),
                ),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: const Text('Thử lại')),
              ],
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      );
    }

    final RecipeDetail detail = _detail!;
    final Recipe recipe = detail.recipe;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              leading: const BackButton(color: Colors.white),
              backgroundColor: const Color(0xFF22C55E),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _buildImage(recipe.imageUrl, recipe.name),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0x33000000), Color(0xAA000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            recipe.name,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: <Widget>[
                              _metaChip(
                                Icons.timer,
                                '${recipe.cookTimeMinutes} phút',
                              ),
                              if (detail.servings != null)
                                _metaChip(
                                  Icons.people,
                                  '${detail.servings} người',
                                ),
                              _metaChip(Icons.speed, recipe.difficulty),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (recipe.description.isNotEmpty) ...<Widget>[
                      Text(
                        recipe.description,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          height: 1.5,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (detail.dietTags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: detail.dietTags
                            .map(
                              (String tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Nguyên liệu (${detail.ingredients.length})',
                      child: Column(
                        children: detail.ingredients.map((
                          RecipeIngredient item,
                        ) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: item.isOptional
                                  ? const Color(0xFFF3F4F6)
                                  : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  item.isOptional
                                      ? Icons.check_box_outline_blank
                                      : Icons.check_circle,
                                  color: item.isOptional
                                      ? const Color(0xFF6B7280)
                                      : const Color(0xFF22C55E),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.name.isNotEmpty
                                        ? item.name
                                        : 'Nguyên liệu',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ),
                                if (item.amount.isNotEmpty)
                                  Text(
                                    item.amount,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        Text(
                          'Các bước nấu (${detail.steps.length})',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: detail.steps.isEmpty
                              ? null
                              : () {
                                  context.push(
                                    '${AppRoutes.detailStepBase}/${Uri.encodeComponent(widget.recipeId)}?step=0',
                                  );
                                },
                          child: Text(
                            'Xem từng bước',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF22C55E),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _sectionCard(
                      title: 'Danh sách bước',
                      child: Column(
                        children: detail.steps.map((RecipeStep step) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${step.stepNumber == 0 ? '?' : step.stepNumber}',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      if (step.title.isNotEmpty)
                                        Text(
                                          step.title,
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                      Text(
                                        step.description,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          height: 1.45,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                      if (step.durationMinutes != null ||
                                          (step.tip ?? '').isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 6,
                                          ),
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 6,
                                            children: <Widget>[
                                              if (step.durationMinutes != null)
                                                Text(
                                                  '${step.durationMinutes} phút',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: const Color(
                                                      0xFF6B7280,
                                                    ),
                                                  ),
                                                ),
                                              if ((step.tip ?? '').isNotEmpty)
                                                Text(
                                                  'Tip: ${step.tip}',
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: const Color(
                                                      0xFF6B7280,
                                                    ),
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
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: detail.steps.isEmpty
                            ? null
                            : () {
                                context.push(
                                  '${AppRoutes.detailStepBase}/${Uri.encodeComponent(widget.recipeId)}?step=0',
                                );
                              },
                        child: Text(
                          'Bắt đầu nấu',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String rawUrl, String recipeName) {
    final String url = RecipeImageUtils.resolveRecipeImageUrl(
      rawUrl: rawUrl,
      recipeName: recipeName,
    );

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFE5E7EB),
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 36,
            color: Color(0xFF9CA3AF),
          ),
        );
      },
    );
  }
}
