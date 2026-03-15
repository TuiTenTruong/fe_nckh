import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.currentIndex});

  final int? currentIndex;

  static const List<_NavItemData> _items = <_NavItemData>[
    _NavItemData(icon: Icons.home, label: 'Trang chủ', routeName: '/home'),
    _NavItemData(icon: Icons.qr_code_2, label: 'Quét', routeName: '/search'),
    _NavItemData(
      icon: Icons.restaurant_menu,
      label: 'Công thức',
      routeName: '/recipe',
    ),
    _NavItemData(icon: Icons.chat, label: 'Chat AI', routeName: '/favorites'),
    _NavItemData(icon: Icons.person, label: 'Hồ sơ', routeName: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List<Widget>.generate(_items.length, (int index) {
          final _NavItemData item = _items[index];
          final bool isActive = currentIndex == index;

          return Expanded(
            child: InkWell(
              onTap: () {
                if (!isActive) {
                  context.go(item.routeName);
                }
              },
              child: _NavItem(
                icon: item.icon,
                label: item.label,
                isActive: isActive,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          icon,
          color: isActive ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isActive ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  final IconData icon;
  final String label;
  final String routeName;
}
