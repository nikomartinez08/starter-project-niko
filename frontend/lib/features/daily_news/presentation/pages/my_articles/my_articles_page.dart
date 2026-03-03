import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/draft/draft_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/draft/draft_state.dart';

class MyArticlesPage extends StatelessWidget {
  const MyArticlesPage({Key? key}) : super(key: key);

  static const _bg = Color(0xFF0A0A0A);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(height: 1, thickness: 1, color: _border),
            Expanded(
              child: BlocBuilder<DraftCubit, DraftState>(
                builder: (context, state) {
                  if (state is DraftsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is DraftError) {
                    return Center(
                      child: Text(state.message,
                          style: const TextStyle(color: _secondaryText)),
                    );
                  }
                  if (state is DraftsLoaded && state.drafts.isNotEmpty) {
                    return _buildList(context, state.drafts);
                  }
                  return _buildEmpty(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'My Articles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/UploadArticle'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 56, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'No articles yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start writing your first article',
            style: TextStyle(color: _secondaryText, fontSize: 14),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/UploadArticle'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Write something',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DraftEntity> drafts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: drafts.length,
      itemBuilder: (context, index) => _ArticleCard(
        draft: drafts[index],
        onTap: () => Navigator.pushNamed(
          context,
          '/UploadArticle',
          arguments: drafts[index],
        ),
        onDelete: () {
          if (drafts[index].id != null) {
            context.read<DraftCubit>().deleteDraft(drafts[index].id!);
          }
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final DraftEntity draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);
  static const _mutedText = Color(0xFF636366);

  const _ArticleCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(draft.id ?? draft.title),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Article', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This article will be permanently deleted.',
            style: TextStyle(color: _secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        draft.title?.isNotEmpty == true ? draft.title! : 'Untitled',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (draft.content?.isNotEmpty == true) ...[
                        const SizedBox(height: 6),
                        Text(
                          draft.content!
                              .replaceAll(RegExp(r'[#*_~`>\[\]!-]'), '')
                              .trim(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _secondaryText,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: const Text(
                              'DRAFT',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(draft.updatedAt),
                            style: const TextStyle(color: _mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Image thumbnail
              if (draft.imagePath != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 12, 14),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildThumbnail(draft.imagePath!),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(right: 14, top: 16),
                  child: Icon(Icons.chevron_right_rounded, color: _mutedText, size: 18),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(String path) {
    final isUrl = path.startsWith('http://') || path.startsWith('https://');
    if (isUrl) {
      return Image.network(
        path,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      );
    }
    return Image.file(
      File(path),
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
