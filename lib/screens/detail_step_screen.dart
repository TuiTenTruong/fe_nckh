import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class DetailStepScreen extends StatefulWidget {
  const DetailStepScreen({
    super.key,
    required this.recipeId,
    this.initialStep = 0,
  });

  final String recipeId;
  final int initialStep;

  @override
  State<DetailStepScreen> createState() => _DetailStepScreenState();
}

class _DetailStepScreenState extends State<DetailStepScreen> {
  final RecipeService _service = const RecipeService();

  bool _isLoading = true;
  String? _error;
  RecipeDetail? _detail;
  int _index = 0;

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

      final int maxIndex = detail.steps.isEmpty ? 0 : detail.steps.length - 1;
      final int startIndex = widget.initialStep.clamp(0, maxIndex);

      setState(() {
        _detail = detail;
        _index = startIndex;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được các bước nấu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF9FAFB),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: AppBottomNavBar(currentIndex: 2),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
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
    if (detail.steps.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Center(
          child: Text(
            'Công thức này chưa có bước nấu.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
      );
    }

    final RecipeStep step = detail.steps[_index];
    final int total = detail.steps.length;
    final int displayNumber = step.stepNumber == 0
        ? _index + 1
        : step.stepNumber;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Color(0xFF1F2937)),
        centerTitle: true,
        title: Text(
          'Bước $displayNumber/$total',
          style: GoogleFonts.inter(
            color: const Color(0xFF6B7280),
            fontSize: 14,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_index + 1) / total,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_index + 1} / $total',
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x19000000),
                      spreadRadius: -4,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color(0x19000000),
                      spreadRadius: -3,
                      offset: Offset(0, 10),
                      blurRadius: 15,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$displayNumber',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Bước $displayNumber',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF1F2937),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              step.description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color(0xFF6B7280),
                fontSize: 18,
                height: 1.6,
              ),
            ),
            if ((step.tip ?? '').isNotEmpty) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                'Tip: ${step.tip}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF4B5563),
                  fontSize: 14,
                ),
              ),
            ],
            if (step.durationMinutes != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                '${step.durationMinutes} phút',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
            ],
            const Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(
                        width: 1.6,
                        color: Color(0xFFE5E7EB),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _index == 0
                        ? null
                        : () {
                            setState(() {
                              _index -= 1;
                            });
                          },
                    child: Text(
                      'Bước trước',
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1F2937),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_index == total - 1) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hoàn thành công thức!'),
                          ),
                        );

                        Navigator.of(context).pop();
                        return;
                      }

                      setState(() {
                        _index += 1;
                      });
                    },
                    child: Text(
                      _index == total - 1 ? 'Hoàn tất' : 'Bước tiếp',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 2),
    );
  }
}
