import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';

class ArticleDetailsView extends HookWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _bodyText = Color(0xFFD1D1D6);
  static const _secondaryText = Color(0xFF8E8E93);
  static const _mutedText = Color(0xFF636366);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocalArticleBloc>(),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            // ── Scrollable article content ────────────────────────────────
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroImage(),
                  _buildContent(),
                ],
              ),
            ),

            // ── Floating action row (back + save) over the image ──────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FloatingBtn(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    Builder(
                      builder: (ctx) => _FloatingBtn(
                        icon: Icons.bookmark_outline_rounded,
                        onTap: () => _saveArticle(ctx),
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

  // ── Hero image ────────────────────────────────────────────────────────────

  Widget _buildHeroImage() {
    final String imageUrl = article?.urlToImage ?? '';

    return Stack(
      children: [
        // Image
        Container(
          width: double.infinity,
          height: 320,
          color: _surface,
          child: imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 320,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: Colors.white12,
                      size: 52,
                    ),
                  ),
                )
              : const Center(
                  child: Icon(
                    Icons.article_rounded,
                    color: Colors.white12,
                    size: 64,
                  ),
                ),
        ),
        // Gradient fade into background
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [_bg, Colors.transparent],
                stops: [0.0, 0.52],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Article content ───────────────────────────────────────────────────────

  Widget _buildContent() {
    // Clean up content — strip the "[+XXXX chars]" API truncation marker
    final description = article?.description ?? '';
    final rawContent = article?.content ?? '';
    final content = rawContent.replaceAll(RegExp(r'\s*\[\+\d+ chars\]$'), '').trim();

    final body = [description, content]
        .where((s) => s.isNotEmpty)
        .join('\n\n');

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            article?.title ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),

          // Author · date
          Row(
            children: [
              if ((article?.author ?? '').isNotEmpty) ...[
                Flexible(
                  child: Text(
                    article!.author!,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('·', style: TextStyle(color: _mutedText)),
                ),
              ],
              Text(
                _formatDate(article?.publishedAt),
                style: const TextStyle(color: _mutedText, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Divider
          Container(height: 1, color: _border),
          const SizedBox(height: 22),

          // Body text
          Text(
            body.isNotEmpty ? body : 'No content available.',
            style: const TextStyle(
              color: _bodyText,
              fontSize: 16,
              height: 1.85,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _saveArticle(BuildContext context) {
    if (article == null) return;
    BlocProvider.of<LocalArticleBloc>(context).add(SaveArticle(article!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Saved to your library',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

// ── Floating pill button ───────────────────────────────────────────────────

class _FloatingBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FloatingBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}
