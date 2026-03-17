import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/models.dart';
import '../services/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const String _userId = 'mobile-demo-user';

  bool _isLoading = true;
  final int _favoriteCount = 12;
  final int _cookedCount = 45;
  int _scanHistoryCount = 0;
  int _pantryCount = 0;
  int _pendingSyncCount = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfileStats();
  }

  Future<void> _loadProfileStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Run network sync in background so profile stats can appear faster.
      ServiceDemo.triggerPantrySync(userId: _userId).catchError((Object e) {
        debugPrint('[Profile] Background sync error: $e');
      });

      int historyCount = 0;
      List<PantryItem> pantry = <PantryItem>[];
      int pending = 0;
      int failCount = 0;

      try {
        historyCount = await ScanLocalStorageService.getHistoryCount();
      } catch (e) {
        failCount++;
        debugPrint('[Profile] History load failed: $e');
      }

      try {
        pantry = await ServiceDemo.getPantry(userId: _userId);
      } catch (e) {
        failCount++;
        debugPrint('[Profile] Pantry load failed: $e');
      }

      try {
        pending = await ServiceDemo.getPendingSyncCount();
      } catch (e) {
        failCount++;
        debugPrint('[Profile] Pending queue load failed: $e');
      }

      if (!mounted) return;
      setState(() {
        _scanHistoryCount = historyCount;
        _pantryCount = pantry.length;
        _pendingSyncCount = pending;
        _error = failCount == 3 ? 'Khong the tai du lieu ho so.' : null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
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
          colors: <Color>[Color(0xFFF0FFF5), Colors.white],
        ),
      ),
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadProfileStats,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
            children: <Widget>[
              _ProfileHeader(
                favoriteCount: _favoriteCount,
                cookedCount: _cookedCount,
                pantryCount: _pantryCount,
                pendingSyncCount: _pendingSyncCount,
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const _ProfileLoadingSkeleton()
              else if (_error != null)
                _InlineError(message: _error!, onRetry: _loadProfileStats)
              else
                _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: <Widget>[
        _ActionCard(
          icon: Icons.kitchen_outlined,
          title: 'Nguyên liệu của tôi',
          subtitle: 'Bạn đang có $_pantryCount nguyên liệu trong kho',
          onTap: () => context.push('/history-recognize?tab=pantry'),
        ),
        const SizedBox(height: 10),
        _ActionCard(
          icon: Icons.history,
          title: 'Lịch sử quét nguyên liệu',
          subtitle: 'Bạn đã quét $_scanHistoryCount lần',
          onTap: () => context.push('/history-recognize?tab=history'),
        ),
        const SizedBox(height: 10),
        _ActionCard(
          icon: Icons.settings_outlined,
          title: 'Cài đặt',
          subtitle: 'Tùy chỉnh ứng dụng theo nhu cầu',
          onTap: () => context.push('/settings'),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.favoriteCount,
    required this.cookedCount,
    required this.pantryCount,
    required this.pendingSyncCount,
  });

  final int favoriteCount;
  final int cookedCount;
  final int pantryCount;
  final int pendingSyncCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF22C55E), Color(0xFF00A63E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/svg/profile_avatar.svg',
                    width: 42,
                    height: 42,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Người dùng',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Thành viên từ 03/2026',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pendingSyncCount > 0) ...<Widget>[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Đang có $pendingSyncCount thay đổi chờ đồng bộ khi trực tuyến.',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: _StatBox(
                  label: 'Món yêu thích',
                  value: '$favoriteCount',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(label: 'Đã nấu', value: '$cookedCount'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatBox(
                  label: 'Kho nguyên liệu',
                  value: '$pantryCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: <Widget>[
          Text(
            value,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF16A34A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: const Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
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
            'Không tải được thông tin hồ sơ',
            style: GoogleFonts.inter(
              color: const Color(0xFF991B1B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: const Color(0xFFB91C1C),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _ProfileLoadingSkeleton extends StatelessWidget {
  const _ProfileLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const _SkeletonLine(height: 64, radius: 16),
        const SizedBox(height: 10),
        const _SkeletonLine(height: 64, radius: 16),
        const SizedBox(height: 10),
        const _SkeletonLine(height: 64, radius: 16),
      ],
    );
  }
}

class _SkeletonLine extends StatefulWidget {
  const _SkeletonLine({required this.height, required this.radius});

  final double height;
  final double radius;

  @override
  State<_SkeletonLine> createState() => _SkeletonLineState();
}

class _SkeletonLineState extends State<_SkeletonLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.4,
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
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(widget.radius),
            ),
          ),
        );
      },
    );
  }
}
