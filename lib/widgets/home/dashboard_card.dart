import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.icon,
    required this.titleAr,
    required this.titleEn,
    required this.colors,
    required this.onTap,
  });

  final IconData icon;
  final String titleAr;
  final String titleEn;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 22,
      shadowColor: colors.first.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    titleAr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    titleEn,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
