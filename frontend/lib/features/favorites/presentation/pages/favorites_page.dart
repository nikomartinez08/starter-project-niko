import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/favorites/domain/entities/favorite_article.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

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
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  if (state is FavoritesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is FavoritesError) {
                    return Center(
                      child: Text(state.message, style: const TextStyle(color: _secondaryText)),
                    );
                  }
                  if (state is FavoritesLoaded && state.favorites.isNotEmpty) {
                    return _buildList(context, state.favorites);
                  }
                  return _buildEmpty();
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
          const Text(
            'Saved',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline_rounded, size: 56, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'Nothing saved yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bookmark articles to read them later',
            style: TextStyle(color: _secondaryText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<FavoriteArticleEntity> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      itemCount: favorites.length,
      itemBuilder: (context, index) => _FavoriteCard(
        article: favorites[index],
        onTap: () => _navigateToDetail(context, favorites[index]),
        onRemove: () =>
            context.read<FavoritesBloc>().add(ToggleFavoriteEvent(favorites[index])),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, FavoriteArticleEntity fav) {
    final article = ArticleEntity(
      author: fav.author,
      title: fav.title,
      description: fav.description,
      url: fav.url,
      urlToImage: fav.urlToImage,
      publishedAt: fav.publishedAt,
      content: fav.content,
    );
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteArticleEntity article;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);
  static const _mutedText = Color(0xFF636366);

  const _FavoriteCard({
    required this.article,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(article.externalId ?? article.title),
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
        child: const Icon(Icons.bookmark_remove_rounded, color: Colors.red, size: 24),
      ),
      onDismissed: (_) => onRemove(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 96,
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: _buildThumbnail(),
              ),
              // Text content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.title ?? 'No title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Row(
                        children: [
                          if ((article.author ?? '').isNotEmpty) ...[
                            Flexible(
                              child: Text(
                                article.author!,
                                style: const TextStyle(color: _secondaryText, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text('·', style: TextStyle(color: _mutedText)),
                            ),
                          ],
                          Text(
                            _formatDate(article.publishedAt),
                            style: const TextStyle(color: _mutedText, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded, color: _mutedText, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final url = article.urlToImage ?? '';
    if (url.isEmpty) {
      return Container(
        width: 96,
        height: 96,
        color: const Color(0xFF2C2C2E),
        child: Icon(Icons.image_rounded, color: Colors.grey[700]),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: 96,
      height: 96,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(width: 96, height: 96, color: const Color(0xFF2C2C2E)),
      errorWidget: (_, __, ___) => Container(
        width: 96,
        height: 96,
        color: const Color(0xFF2C2C2E),
        child: Icon(Icons.broken_image_rounded, color: Colors.grey[700]),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
