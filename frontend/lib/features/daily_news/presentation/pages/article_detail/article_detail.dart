import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../domain/entities/article.dart';
import '../../../../favorites/domain/entities/favorite_article.dart';
import '../../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../../favorites/presentation/bloc/favorites_state.dart';

class ArticleDetailsView extends StatefulWidget {
  final ArticleEntity? article;

  const ArticleDetailsView({Key? key, this.article}) : super(key: key);

  @override
  State<ArticleDetailsView> createState() => _ArticleDetailsViewState();
}

class _ArticleDetailsViewState extends State<ArticleDetailsView> {
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _bodyText = Color(0xFFD1D1D6);
  static const _secondaryText = Color(0xFF8E8E93);
  static const _mutedText = Color(0xFF636366);

  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(GetFavorites());
  }

  bool _checkIfSaved(List<FavoriteArticleEntity>? savedArticles) {
    if (savedArticles == null || widget.article == null) return false;
    final title = widget.article!.title;
    return savedArticles.any((a) => a.title == title);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (context, state) {
        if (state is FavoritesLoaded) {
          setState(() => _isSaved = _checkIfSaved(state.favorites));
        }
      },
      builder: (context, state) {
        // Fallback check if state is already loaded but listener didn't fire (e.g. initial build)
        if (state is FavoritesLoaded && !_isSaved) {
           _isSaved = _checkIfSaved(state.favorites);
        }
        
        return Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroImage(),
                    _buildContent(),
                  ],
                ),
              ),
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
                      _FloatingBtn(
                        icon: _isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        onTap: () => _toggleSave(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroImage() {
    final String imageUrl = widget.article?.urlToImage ?? '';

    return Stack(
      children: [
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

  Widget _buildContent() {
    final description = widget.article?.description ?? '';
    final rawContent = widget.article?.content ?? '';
    final content = rawContent.replaceAll(RegExp(r'\s*\[\+\d+ chars\]$'), '').trim();

    final body = [description, content]
        .where((s) => s.isNotEmpty)
        .join('\n\n');

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.article?.title ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              if ((widget.article?.author ?? '').isNotEmpty) ...[
                Flexible(
                  child: Text(
                    widget.article!.author!,
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
                _formatDate(widget.article?.publishedAt),
                style: const TextStyle(color: _mutedText, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(height: 1, color: _border),
          const SizedBox(height: 22),
          body.isNotEmpty
              ? MarkdownBody(
                  data: body,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                    h1: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    h2: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    h3: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    p: const TextStyle(
                      color: _bodyText,
                      fontSize: 16,
                      height: 1.85,
                      letterSpacing: 0.1,
                    ),
                    strong: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      height: 1.85,
                    ),
                    em: const TextStyle(
                      color: Color(0xFFD0D0D0),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.85,
                    ),
                    a: const TextStyle(color: Color(0xFF6B9FFF)),
                    del: TextStyle(color: Colors.grey[600]),
                    listBullet: const TextStyle(color: _secondaryText, fontSize: 16),
                    code: const TextStyle(
                      color: Color(0xFFE8C07D),
                      backgroundColor: Color(0xFF2C2C2E),
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _border),
                    ),
                    codeblockPadding: const EdgeInsets.all(16),
                    blockquoteDecoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Color(0xFF6B9FFF), width: 3),
                      ),
                    ),
                    blockquotePadding:
                        const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                    horizontalRuleDecoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: _border, width: 1),
                      ),
                    ),
                  ),
                )
              : const Text(
                  'No content available.',
                  style: TextStyle(
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

  void _toggleSave(BuildContext context) {
    if (widget.article == null) return;
    
    final favorite = FavoriteArticleEntity(
      externalId: widget.article!.url ?? widget.article!.title ?? '',
      author: widget.article!.author ?? 'Unknown',
      title: widget.article!.title ?? '',
      description: widget.article!.description ?? '',
      url: widget.article!.url ?? '',
      urlToImage: widget.article!.urlToImage ?? '',
      savedAt: DateTime.now(),
      content: widget.article!.content,
      publishedAt: widget.article!.publishedAt,
    );

    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(favorite));
    
    // Optimistic UI update
    setState(() => _isSaved = !_isSaved);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isSaved ? 'Saved to your library' : 'Removed from library', 
          style: const TextStyle(color: Colors.white)
        ),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

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
