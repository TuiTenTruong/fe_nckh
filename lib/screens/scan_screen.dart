import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/models.dart';
import '../services/services.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  static const String _demoUserId = 'mobile-demo-user';

  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _manualIngredientController =
      TextEditingController();

  bool _isScanning = false;
  String? _scanError;
  String? _scanSessionId;
  Uint8List? _capturedImageBytes;
  List<ScanDetection> _detected = <ScanDetection>[];

  @override
  void dispose() {
    _manualIngredientController.dispose();
    super.dispose();
  }

  Future<void> _scanWithSystemCamera() async {
    if (_isScanning) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
        maxWidth: 1920,
      );

      if (image == null) return;

      final Uint8List imageBytes = await image.readAsBytes();
      await _submitScan(imageBytes: imageBytes, fileName: image.name);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _scanError = 'Không thể mở camera hệ thống: $e';
      });
    }
  }

  Future<void> _submitScan({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    if (!mounted) return;

    setState(() {
      _isScanning = true;
      _scanError = null;
      _capturedImageBytes = imageBytes;
    });

    try {
      final ScanResult result = await ServiceDemo.scanImageBytes(
        userId: _demoUserId,
        imageBytes: imageBytes,
        fileName: fileName,
      );

      await ScanLocalStorageService.saveScanResult(result);

      if (!mounted) return;
      setState(() {
        _scanSessionId = result.scanId;
        _detected = result.items;
        _isScanning = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _scanError = e.toString();
      });
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _detected = List<ScanDetection>.from(_detected)..removeAt(index);
    });
  }

  void _addManualIngredient() {
    final String raw = _manualIngredientController.text.trim();
    if (raw.isEmpty) {
      return;
    }

    setState(() {
      _detected = <ScanDetection>[
        ScanDetection(
          detectedName: raw,
          confidence: 1,
          matched: false,
          ingredientName: raw,
          ingredientIcon: '🥬',
        ),
        ..._detected,
      ];
      _manualIngredientController.clear();
    });
  }

  void _goFindRecipesWithIngredients() {
    final Set<String> names = _detected
        .map(
          (ScanDetection item) =>
              (item.ingredientName ?? item.detectedName).trim(),
        )
        .where((String name) => name.isNotEmpty)
        .toSet();

    if (names.isEmpty) {
      context.go('/recipe');
      return;
    }

    final String joined = names.join(',');
    context.go('/recipe?ingredients=${Uri.encodeComponent(joined)}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFF6FFF9), Color(0xFFEFFAF3)],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: <Widget>[
          _ScanHero(
            imageBytes: _capturedImageBytes,
            isScanning: _isScanning,
            onScanNow: _scanWithSystemCamera,
          ),
          const SizedBox(height: 14),
          _ActionToolbar(
            canFindRecipes: !_isScanning,
            onFindRecipes: _goFindRecipesWithIngredients,
          ),
          const SizedBox(height: 12),
          _ManualIngredientCard(
            controller: _manualIngredientController,
            onAddTap: _addManualIngredient,
          ),
          const SizedBox(height: 14),
          if (_scanError != null)
            _InlineErrorCard(message: _scanError!)
          else
            const SizedBox.shrink(),
          if (_scanError != null) const SizedBox(height: 14),
          _ResultHeader(
            count: _detected.length,
            sessionId: _scanSessionId,
            isScanning: _isScanning,
          ),
          const SizedBox(height: 10),
          if (_isScanning)
            const _ScanResultSkeleton()
          else if (_detected.isEmpty)
            const _EmptyResultCard()
          else
            ...List<Widget>.generate(
              _detected.length,
              (int index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ResultTile(
                  item: _detected[index],
                  onDelete: () => _removeIngredient(index),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanHero extends StatelessWidget {
  const _ScanHero({
    required this.imageBytes,
    required this.isScanning,
    required this.onScanNow,
  });

  final Uint8List? imageBytes;
  final bool isScanning;
  final VoidCallback onScanNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Nhận diện nguyên liệu',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF14532D),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isScanning
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isScanning ? 'Đang quét' : 'Sẵn sàng',
                  style: GoogleFonts.inter(
                    color: isScanning
                        ? const Color(0xFF92400E)
                        : const Color(0xFF166534),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Container(
              height: 210,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
                ),
              ),
              child: imageBytes == null
                  ? Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            color: const Color(0xFFF0FDF4),
                            child: SvgPicture.asset(
                              'assets/svg/scan_bg.svg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 190,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFBBF7D0),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.photo_camera_outlined,
                                  color: Color(0xFF16A34A),
                                  size: 24,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Chưa có ảnh quét',
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF166534),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Nhấn nút bên dưới để mở camera và nhận diện nguyên liệu.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: const Color(0xFF166534),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Image.memory(imageBytes!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              'Ảnh đã chụp',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isScanning ? null : onScanNow,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                minimumSize: const Size(0, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: isScanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt_outlined),
              label: Text(
                isScanning
                    ? 'Đang gửi ảnh lên hệ thống...'
                    : 'Mở camera và quét',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionToolbar extends StatelessWidget {
  const _ActionToolbar({
    required this.canFindRecipes,
    required this.onFindRecipes,
  });

  final bool canFindRecipes;
  final VoidCallback onFindRecipes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: canFindRecipes ? onFindRecipes : null,
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 46),
          backgroundColor: const Color(0xFF22C55E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.auto_awesome),
        label: Text(
          'Tìm món ăn',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: Color(0xFFB91C1C)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFFB91C1C),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultHeader extends StatelessWidget {
  const _ResultHeader({
    required this.count,
    required this.sessionId,
    required this.isScanning,
  });

  final int count;
  final String? sessionId;
  final bool isScanning;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Kết quả nhận diện ($count)',
                style: GoogleFonts.inter(
                  color: const Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (sessionId != null)
                Text(
                  'Session: $sessionId',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        if (isScanning)
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF16A34A),
            ),
          ),
      ],
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        'Chưa có nguyên liệu nào. Hãy quét hoặc thêm tay để bắt đầu tìm món ăn.',
        style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13),
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.item, required this.onDelete});

  final ScanDetection item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final bool matched = item.matched;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: matched ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: matched
                  ? const Color(0xFFECFDF3)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                item.ingredientIcon ?? '🥬',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.ingredientName ?? item.detectedName,
                  style: GoogleFonts.inter(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  matched
                      ? 'Đã đối chiếu với cơ sở dữ liệu'
                      : 'Nguyên liệu bạn thêm thủ công hoặc cần kiểm tra',
                  style: GoogleFonts.inter(
                    color: matched
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _ManualIngredientCard extends StatelessWidget {
  const _ManualIngredientCard({
    required this.controller,
    required this.onAddTap,
  });

  final TextEditingController controller;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD1FAE5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Thêm nguyên liệu thủ công',
            style: GoogleFonts.inter(
              color: const Color(0xFF14532D),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAddTap(),
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Tôm, Cà rốt, Khoai tây...',
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onAddTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Thêm',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanResultSkeleton extends StatefulWidget {
  const _ScanResultSkeleton();

  @override
  State<_ScanResultSkeleton> createState() => _ScanResultSkeletonState();
}

class _ScanResultSkeletonState extends State<_ScanResultSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _controller.value,
          child: Column(
            children: List<Widget>.generate(
              3,
              (_) => Container(
                width: double.infinity,
                height: 68,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
