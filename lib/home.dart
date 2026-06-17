import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';
import 'widgets/home/dashboard_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildWelcomeCard(user),
              const SizedBox(height: 32),
              _buildSectionTitle(),
              const SizedBox(height: 20),
              Expanded(child: _buildDashboardCards(context)),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('لوحة التحكم', style: Theme.of(context).appBarTheme.titleTextStyle),
      centerTitle: true,
      backgroundColor: AppTheme.surface,
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: AppTheme.textPrimary),
          onPressed: () => _signOut(context),
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الخروج')),
      );
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  Widget _buildWelcomeCard(User? user) {
    final name = user?.displayName?.trim().isNotEmpty == true 
        ? user!.displayName 
        : user?.email?.split('@').first ?? 'المسؤول';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'مرحباً، $name',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'نظام إدارة المحتوى المتكامل',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.waving_hand, color: AppTheme.primary, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'اختر القسم المراد إدارته',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.dashboard_customize_rounded, size: 22, color: AppTheme.textPrimary),
      ],
    );
  }

  Widget _buildDashboardCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DashboardCard(
            icon: Icons.article_rounded,
            titleAr: 'إدارة الأخبار',
            titleEn: 'News Management',
            colors: [AppTheme.primary, const Color(0xFF1565C0)],
            onTap: () => Navigator.of(context).pushNamed('/news'),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: DashboardCard(
            icon: Icons.school_rounded,
            titleAr: 'المحتوى الأكاديمي',
            titleEn: 'Academic Content',
            colors: [AppTheme.accent, const Color(0xFF2E7D32)],
            onTap: () => Navigator.of(context).pushNamed('/academic'),
          ),
        ),
      ],
    );
  }
}