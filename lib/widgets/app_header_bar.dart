import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AppHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  const AppHeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIconUrl,
  });

  final String title;
  final String subtitle;
  final String? leadingIconUrl;

  @override
  Size get preferredSize => const Size.fromHeight(148);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF23C35B),
            Color(0xFF119E4B),
            Color(0xFF0E8F42),
          ],
          stops: <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: preferredSize.height,
        child: Stack(
          children: <Widget>[
            const Positioned(
              right: -26,
              top: -24,
              child: _GlowBubble(size: 112, opacity: 0.16),
            ),
            const Positioned(
              left: -38,
              bottom: -54,
              child: _GlowBubble(size: 156, opacity: 0.11),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0x26FFFFFF),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0x40FFFFFF),
                              width: 0.7,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.restaurant_menu_rounded,
                              size: 20,
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              height: 1.15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x26FFFFFF),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0x40FFFFFF),
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            'AI',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Cai dat',
                          onPressed: () => context.push('/settings'),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0x26FFFFFF),
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0x40FFFFFF),
                              width: 0.7,
                            ),
                          ),
                          icon: const Icon(Icons.settings_outlined, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        color: const Color(0xE6FFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.42,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBubble extends StatelessWidget {
  const _GlowBubble({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
