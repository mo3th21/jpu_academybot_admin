import 'package:flutter/material.dart';
import 'services/news_service.dart';
import 'theme/app_theme.dart';
import 'utils/firebase_utils.dart';
import 'widgets/news/news_card.dart';
import 'widgets/news/news_form_dialog.dart';
import 'models/news.dart';

class NewsManagementPage extends StatefulWidget {
  const NewsManagementPage({super.key});

  @override
  State<NewsManagementPage> createState() => _NewsManagementPageState();
}

class _NewsManagementPageState extends State<NewsManagementPage> {
  final NewsService _newsService = NewsService();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(
            'إدارة الأخبار',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          centerTitle: true,
          backgroundColor: AppTheme.surface,
          elevation: 2,
        ),
        body: StreamBuilder<List<News>>(
          stream: _newsService.getNews(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error);
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            final newsList = snapshot.data ?? [];
            if (newsList.isEmpty) {
              return _buildEmptyState(context);
            }
            return _buildNewsGrid(context, newsList);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showNewsDialog(context),
          backgroundColor: AppTheme.primary,
          elevation: 6,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'إضافة خبر جديد',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  void _showNewsDialog(BuildContext context, {News? news}) {
    showDialog(
      context: context,
      builder: (context) => NewsFormDialog(
        news: news,
        newsService: _newsService,
      ),
    );
  }

  Future<void> _deleteNews(News news) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تأكيد الحذف',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا الخبر؟',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true && news.id != null) {
      try {
        await _newsService.deleteNews(
          news.id!,
          normalizeFirebaseImageUrl(news.imageUrl),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حذف الخبر بنجاح',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              backgroundColor: AppTheme.accent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ في حذف الخبر: $e'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildErrorState(BuildContext context, Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ: $error',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.error,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        color: AppTheme.primary,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.newspaper,
            size: 80,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أخبار حالياً',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsGrid(BuildContext context, List<News> newsList) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return AspectRatio(
          aspectRatio: 1,
          child: NewsCard(
            news: news,
            onEdit: () => _showNewsDialog(context, news: news),
            onDelete: () => _deleteNews(news),
          ),
        );
      },
    );
  }
}
