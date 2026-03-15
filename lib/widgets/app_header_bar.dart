import 'package:flutter/material.dart';
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

  static const String _defaultLeadingIconUrl =
      'https://storage.googleapis.com/codeless-app.appspot.com/uploads%2Fimages%2F0SN4w0RadPKtOcjLJ2JJ%2F987e5450-06fb-4362-9a06-e76dbbaf738c.png';

  @override
  Size get preferredSize => const Size.fromHeight(132);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: preferredSize.height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        gradient: LinearGradient(
          colors: <Color>[Color(0xFF22C55E), Color(0xFF00A63E)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            left: 24,
            top: 24,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Center(
                child: Image.network(
                  leadingIconUrl ?? _defaultLeadingIconUrl,
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 27,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 80,
            child: Opacity(
              opacity: 0.9,
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
