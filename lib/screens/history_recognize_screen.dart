import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/services.dart';

class HistoryRecognizeScreen extends StatefulWidget {
  const HistoryRecognizeScreen({super.key});

  @override
  State<HistoryRecognizeScreen> createState() => _HistoryRecognizeScreenState();
}

class _HistoryRecognizeScreenState extends State<HistoryRecognizeScreen> {
  bool _isLoading = true;
  String? _error;
  HistoryTimeFilter _timeFilter = HistoryTimeFilter.all;
  List<ScanHistoryItem> _scanHistory = <ScanHistoryItem>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<ScanHistoryItem> history = await ServiceDemo.getScanHistory();

      if (!mounted) return;
      setState(() {
        _scanHistory = history;
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

  List<ScanHistoryItem> get _filteredHistory {
    if (_timeFilter == HistoryTimeFilter.all) {
      return _scanHistory;
    }

    final DateTime now = DateTime.now();
    late DateTime from;

    if (_timeFilter == HistoryTimeFilter.today) {
      from = DateTime(now.year, now.month, now.day);
    } else if (_timeFilter == HistoryTimeFilter.thisWeek) {
      from = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
    } else {
      from = DateTime(now.year, now.month, 1);
    }

    return _scanHistory
        .where((ScanHistoryItem item) => !item.createdAt.isBefore(from))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16A34A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Lịch sử nhận diện',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Theo dõi các phiên quét nguyên liệu',
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        toolbarHeight: 66,
      ),
      body: Material(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[Color(0xFFF5FFF8), Color(0xFFFFFFFF)],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              children: <Widget>[
                _HistorySummary(historyCount: _scanHistory.length),
                const SizedBox(height: 14),
                if (_isLoading)
                  const _HistoryLoadingSkeleton()
                else if (_error != null)
                  _ErrorCard(message: _error!, onRetry: _loadData)
                else
                  _HistoryView(
                    items: _filteredHistory,
                    selectedFilter: _timeFilter,
                    onFilterChanged: (HistoryTimeFilter filter) {
                      setState(() {
                        _timeFilter = filter;
                      });
                    },
                    onScanMore: () => context.go('/search'),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/search'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(
                      'Quét thêm',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum HistoryTimeFilter { all, today, thisWeek, thisMonth }

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.historyCount});

  final int historyCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1FAE5)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.history, color: Color(0xFF16A34A)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bạn có $historyCount phiên quét được lưu cục bộ',
              style: GoogleFonts.inter(
                color: const Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({
    required this.items,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onScanMore,
  });

  final List<ScanHistoryItem> items;
  final HistoryTimeFilter selectedFilter;
  final void Function(HistoryTimeFilter) onFilterChanged;
  final VoidCallback onScanMore;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyStateCard(
        message: 'Chưa có lịch sử quét. Hãy quét một ảnh để bắt đầu.',
        buttonText: 'Quét ngay',
        onTap: onScanMore,
      );
    }

    return Column(
      children: <Widget>[
        _FilterBar(
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
        ),
        const SizedBox(height: 10),
        ...items.map((ScanHistoryItem item) => _HistorySessionCard(item: item)),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final HistoryTimeFilter selectedFilter;
  final void Function(HistoryTimeFilter) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _chip(HistoryTimeFilter.all, 'Tất cả'),
          _chip(HistoryTimeFilter.today, 'Hôm nay'),
          _chip(HistoryTimeFilter.thisWeek, 'Tuần này'),
          _chip(HistoryTimeFilter.thisMonth, 'Tháng này'),
        ],
      ),
    );
  }

  Widget _chip(HistoryTimeFilter filter, String text) {
    final bool selected = selectedFilter == filter;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: selected,
        label: Text(text),
        onSelected: (_) => onFilterChanged(filter),
        selectedColor: const Color(0xFFDCFCE7),
        checkmarkColor: const Color(0xFF15803D),
        side: BorderSide(
          color: selected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
        ),
        labelStyle: GoogleFonts.inter(
          color: selected ? const Color(0xFF166534) : const Color(0xFF475569),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  const _HistorySessionCard({required this.item});

  final ScanHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final String sessionText = item.scanId.length > 8
        ? item.scanId.substring(0, 8)
        : item.scanId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF3),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.history,
                  size: 16,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Phiên $sessionText',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF111827),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatTime(item.createdAt),
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.items.map((ScanDetection detection) {
              final String name =
                  detection.ingredientName ?? detection.detectedName;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: detection.matched
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${detection.ingredientIcon ?? ''} $name',
                  style: GoogleFonts.inter(
                    color: detection.matched
                        ? const Color(0xFF166534)
                        : const Color(0xFF92400E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final String hh = dt.hour.toString().padLeft(2, '0');
    final String mm = dt.minute.toString().padLeft(2, '0');
    final String dd = dt.day.toString().padLeft(2, '0');
    final String mo = dt.month.toString().padLeft(2, '0');
    return '$hh:$mm  $dd/$mo/${dt.year}';
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

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
            'Có lỗi khi tải dữ liệu',
            style: GoogleFonts.inter(
              color: const Color(0xFF991B1B),
              fontWeight: FontWeight.w700,
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
          const SizedBox(height: 10),
          OutlinedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.message,
    required this.buttonText,
    required this.onTap,
  });

  final String message;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            message,
            style: GoogleFonts.inter(
              color: const Color(0xFF475569),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}

class _HistoryLoadingSkeleton extends StatefulWidget {
  const _HistoryLoadingSkeleton();

  @override
  State<_HistoryLoadingSkeleton> createState() =>
      _HistoryLoadingSkeletonState();
}

class _HistoryLoadingSkeletonState extends State<_HistoryLoadingSkeleton>
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
              4,
              (_) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                height: 72,
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
