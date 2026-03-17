import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/models.dart';
import '../services/services.dart';

class HistoryRecognizeScreen extends StatefulWidget {
  const HistoryRecognizeScreen({
    super.key,
    this.initialTab = HistoryTab.pantry,
  });

  final HistoryTab initialTab;

  @override
  State<HistoryRecognizeScreen> createState() => _HistoryRecognizeScreenState();
}

class _HistoryRecognizeScreenState extends State<HistoryRecognizeScreen> {
  static const String _userId = 'mobile-demo-user';

  bool _isLoading = true;
  String? _error;
  late HistoryTab _selectedTab;
  HistoryTimeFilter _timeFilter = HistoryTimeFilter.all;
  List<PantryItem> _pantryItems = <PantryItem>[];
  List<ScanHistoryItem> _scanHistory = <ScanHistoryItem>[];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ServiceDemo.triggerPantrySync(userId: _userId);
      final List<PantryItem> pantry = await ServiceDemo.getPantry(
        userId: _userId,
      );
      final List<ScanHistoryItem> history = await ServiceDemo.getScanHistory();

      if (!mounted) return;
      setState(() {
        _pantryItems = pantry;
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

  Future<void> _removePantryItem(PantryItem item) async {
    try {
      final PantryDeleteOutcome outcome = await ServiceDemo.deletePantryItem(
        userId: _userId,
        item: item,
      );
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(outcome.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Xóa thất bại: $e')));
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
              'Quản lý kho và lịch sử quét nguyên liệu',
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
                _HistorySummary(
                  selectedTab: _selectedTab,
                  pantryCount: _pantryItems.length,
                  historyCount: _scanHistory.length,
                  onTabChanged: (HistoryTab tab) {
                    setState(() {
                      _selectedTab = tab;
                    });
                  },
                ),
                const SizedBox(height: 14),
                if (_isLoading)
                  const _HistoryLoadingSkeleton()
                else if (_error != null)
                  _ErrorCard(message: _error!, onRetry: _loadData)
                else if (_selectedTab == HistoryTab.pantry)
                  _PantryView(
                    items: _pantryItems,
                    onAddTap: () => context.go('/search'),
                    onDeleteTap: _removePantryItem,
                  )
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
                Row(
                  children: <Widget>[
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go('/recipe'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(
                          'Tìm công thức',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/search'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF22C55E),
                            width: 1.4,
                          ),
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.qr_code_scanner,
                          color: Color(0xFF22C55E),
                        ),
                        label: Text(
                          'Quét thêm',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF22C55E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum HistoryTab { pantry, history }

enum HistoryTimeFilter { all, today, thisWeek, thisMonth }

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({
    required this.selectedTab,
    required this.pantryCount,
    required this.historyCount,
    required this.onTabChanged,
  });

  final HistoryTab selectedTab;
  final int pantryCount;
  final int historyCount;
  final void Function(HistoryTab) onTabChanged;

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
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _StatPill(title: 'Kho', value: '$pantryCount'),
              const SizedBox(width: 8),
              _StatPill(title: 'Lịch sử', value: '$historyCount'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SegmentTab(
                    title: 'Kho nguyên liệu',
                    selected: selectedTab == HistoryTab.pantry,
                    onTap: () => onTabChanged(HistoryTab.pantry),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _SegmentTab(
                    title: 'Lịch sử quét',
                    selected: selectedTab == HistoryTab.history,
                    onTap: () => onTabChanged(HistoryTab.history),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: selected
                    ? const Color(0xFF166534)
                    : const Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PantryView extends StatelessWidget {
  const _PantryView({
    required this.items,
    required this.onAddTap,
    required this.onDeleteTap,
  });

  final List<PantryItem> items;
  final VoidCallback onAddTap;
  final void Function(PantryItem item) onDeleteTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyStateCard(
        message:
            'Kho nguyên liệu đang trống. Hãy quét thêm nguyên liệu để bắt đầu.',
        buttonText: 'Mở trang quét',
        onTap: onAddTap,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (BuildContext context, int index) {
        if (index == items.length) {
          return _AddIngredientCard(onTap: onAddTap);
        }

        final PantryItem item = items[index];
        return _PantryItemCard(item: item, onDelete: () => onDeleteTap(item));
      },
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

class _PantryItemCard extends StatelessWidget {
  const _PantryItemCard({required this.item, required this.onDelete});

  final PantryItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      item.ingredientIcon,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        item.ingredientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFF0F172A),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Số lượng: ${item.quantity}',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 4,
            top: 4,
            child: InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddIngredientCard extends StatelessWidget {
  const _AddIngredientCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF22C55E)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.add_circle_outline, color: Color(0xFF22C55E)),
              const SizedBox(height: 6),
              Text(
                'Thêm',
                style: GoogleFonts.inter(
                  color: const Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
