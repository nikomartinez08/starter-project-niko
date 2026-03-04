import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../favorites/domain/entities/favorite_article.dart';
import '../../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../../streaming/presentation/bloc/streaming_bloc.dart';
import '../../../../streaming/presentation/bloc/streaming_state.dart';
import '../../../../streaming/presentation/widgets/live_stream_card.dart';
import '../../../../streaming/domain/entities/live_stream_entity.dart';
import '../../../domain/entities/article.dart';
import '../../../domain/entities/draft.dart';
import '../../bloc/article/remote/remote_article_bloc.dart';
import '../../bloc/article/remote/remote_article_event.dart';
import '../../bloc/article/remote/remote_article_state.dart';
import '../../models/feed_item.dart';

// ─────────────────────────────────────────────
// NEWS FEED CONTENT (embeddable, no Scaffold)
// Vertical scroll = TikTok, Horizontal swipe = Tinder
// ─────────────────────────────────────────────

class NewsFeedContent extends StatefulWidget {
  final Set<String> savedTitles;
  const NewsFeedContent({Key? key, this.savedTitles = const {}}) : super(key: key);

  @override
  State<NewsFeedContent> createState() => _NewsFeedContentState();
}

class _NewsFeedContentState extends State<NewsFeedContent> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage(int totalCount) {
    final nextPage = (_pageController.page?.round() ?? 0) + 1;
    if (nextPage < totalCount) {
      _pageController.jumpToPage(nextPage);
    }
  }

  void _onPageChanged(int index, int totalCount) {
    // Load more when near the end (3 pages before last)
    if (index >= totalCount - 3) {
      context.read<RemoteArticlesBloc>().add(const LoadMoreArticles());
    }
  }

  List<FeedItem> _buildFeedItems(List<ArticleEntity> articles, List<LiveStreamEntity> streams) {
    final items = <FeedItem>[];
    for (final stream in streams) {
      items.add(FeedItem.liveStream(stream));
    }
    for (final article in articles) {
      items.add(FeedItem.article(article));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: BlocBuilder<StreamingBloc, StreamingState>(
          builder: (context, streamingState) {
            final liveStreams = streamingState is ActiveStreamsLoaded
                ? streamingState.streams
                : <LiveStreamEntity>[];

            return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
              builder: (context, state) {
                if (state is RemoteArticlesLoading) {
                  return const Center(
                    child: CupertinoActivityIndicator(color: Colors.white),
                  );
                }

                if (state is RemoteArticlesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 52, color: Colors.grey[700]),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load articles',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => context.read<RemoteArticlesBloc>().add(const GetArticles()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Text(
                              'Retry',
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

                if (state is RemoteArticlesDone) {
                  final allArticles = state.articles ?? [];
                  final articles = widget.savedTitles.isEmpty
                      ? allArticles
                      : allArticles.where((a) => !widget.savedTitles.contains(a.title)).toList();
                  final feedItems = _buildFeedItems(articles, liveStreams);

                  if (feedItems.isEmpty) {
                    return Center(
                      child: Text(
                        'No content found',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<RemoteArticlesBloc>().add(const RefreshArticles());
                      await context.read<RemoteArticlesBloc>().stream.firstWhere(
                        (s) => s is RemoteArticlesDone || s is RemoteArticlesError,
                      );
                    },
                    color: Colors.white,
                    backgroundColor: const Color(0xFF1C1C1E),
                    child: PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: feedItems.length,
                      onPageChanged: (index) => _onPageChanged(index, feedItems.length),
                      itemBuilder: (context, index) {
                        final item = feedItems[index];
                        if (item.type == FeedItemType.liveStream) {
                          return LiveStreamCard(
                            stream: item.liveStream!,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/ViewerScreen',
                              arguments: item.liveStream!,
                            ),
                          );
                        }
                        return _SwipeableCard(
                          article: item.article!,
                          onSwiped: () => _goToNextPage(feedItems.length),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SWIPEABLE CARD (Tinder horizontal on each page)
// ─────────────────────────────────────────────

class _SwipeableCard extends StatefulWidget {
  final ArticleEntity article;
  final VoidCallback? onSwiped;

  const _SwipeableCard({required this.article, this.onSwiped});

  @override
  State<_SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<_SwipeableCard>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  double _cardOpacity = 1.0;
  bool _isAnimating = false;

  late AnimationController _animController;

  static const double _swipeThreshold = 100;
  static const double _maxAngle = 0.4;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
      _dragAngle = (_dragOffset.dx / 300).clamp(-_maxAngle, _maxAngle);
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_isAnimating) return;
    if (_dragOffset.dx.abs() > _swipeThreshold) {
      _animateOff(_dragOffset.dx > 0);
    } else {
      _snapBack();
    }
  }

  void _snapBack() {
    _isAnimating = true;
    final startOffset = _dragOffset;
    final startAngle = _dragAngle;

    _animController.reset();
    final animation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    animation.addListener(() {
      setState(() {
        _dragOffset = Offset.lerp(startOffset, Offset.zero, animation.value)!;
        _dragAngle = startAngle * (1 - animation.value);
      });
    });
    _animController.forward().then((_) {
      _isAnimating = false;
    });
  }

  void _animateOff(bool toRight) {
    _isAnimating = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final targetX = toRight ? screenWidth * 1.5 : -screenWidth * 1.5;
    final targetAngle = toRight ? _maxAngle : -_maxAngle;
    final startOffset = _dragOffset;
    final startAngle = _dragAngle;

    _animController.reset();
    final animation =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    animation.addListener(() {
      setState(() {
        _dragOffset = Offset.lerp(
            startOffset, Offset(targetX, 0), animation.value)!;
        _dragAngle =
            startAngle + (targetAngle - startAngle) * animation.value;
        _cardOpacity = (1.0 - animation.value).clamp(0.0, 1.0);
      });
    });

    // Fire the action
    if (toRight) {
      _onSwipeRight();
    } else {
      _onSwipeLeft();
    }

    _animController.forward().then((_) {
      // Reset card state so it looks normal when user scrolls back
      setState(() {
        _dragOffset = Offset.zero;
        _dragAngle = 0;
        _cardOpacity = 1.0;
        _isAnimating = false;
      });
      // Instantly show next article
      widget.onSwiped?.call();
    });
  }

  void _onSwipeRight() {
    final article = widget.article;
    final favorite = FavoriteArticleEntity(
      externalId: article.url ?? article.title ?? '',
      author: article.author ?? 'Unknown',
      title: article.title ?? '',
      description: article.description ?? '',
      url: article.url ?? '',
      urlToImage: article.urlToImage ?? '',
      savedAt: DateTime.now(),
    );
    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(favorite));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to favorites'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _onSwipeLeft() {
    final article = widget.article;
    final draft = DraftEntity(
      title: article.title,
      content: article.description ?? article.content,
      imagePath: article.urlToImage,
      author: article.author,
    );
    Navigator.pushNamed(context, '/UploadArticle', arguments: draft);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Hint labels behind the card
        Positioned.fill(
          child: Row(
            children: [
              // Left side — EDIT hint
              Expanded(
                child: Container(
                  color: Colors.blue[900]!.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.white38, size: 40),
                        SizedBox(height: 8),
                        Text('EDIT',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              // Right side — SAVE hint
              Expanded(
                child: Container(
                  color: Colors.green[900]!.withValues(alpha: 0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite, color: Colors.white38, size: 40),
                        SizedBox(height: 8),
                        Text('SAVE',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Draggable card on top
        Opacity(
          opacity: _cardOpacity,
          child: GestureDetector(
            onHorizontalDragUpdate: _onHorizontalDragUpdate,
            onHorizontalDragEnd: _onHorizontalDragEnd,
            onTap: () {
              Navigator.pushNamed(context, '/ArticleDetails', arguments: widget.article);
            },
            child: Transform.translate(
              offset: _dragOffset,
              child: Transform.rotate(
                angle: _dragAngle,
                child: Stack(
                fit: StackFit.expand,
                children: [
                  _NewsCard(article: widget.article),

                  // SAVE overlay (swipe right)
                  if (_dragOffset.dx > 20)
                    Container(
                      color: Colors.green.withValues(
                          alpha: (_dragOffset.dx / 200).clamp(0.0, 0.5)),
                      child: Center(
                        child: Opacity(
                          opacity:
                              ((_dragOffset.dx - 20) / 100).clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: -0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SAVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // EDIT overlay (swipe left)
                  if (_dragOffset.dx < -20)
                    Container(
                      color: Colors.blue.withValues(
                          alpha:
                              (_dragOffset.dx.abs() / 200).clamp(0.0, 0.5)),
                      child: Center(
                        child: Opacity(
                          opacity: ((_dragOffset.dx.abs() - 20) / 100)
                              .clamp(0.0, 1.0),
                          child: Transform.rotate(
                            angle: 0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.white, width: 3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'EDIT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// NEWS FEED SCREEN (standalone route wrapper)
// ─────────────────────────────────────────────

class NewsFeedScreen extends StatelessWidget {
  const NewsFeedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: NewsFeedContent(),
    );
  }
}

// ─────────────────────────────────────────────
// NEWS CARD (full-screen item using ArticleEntity)
// ─────────────────────────────────────────────

class _NewsCard extends StatelessWidget {
  final ArticleEntity article;

  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _BackgroundImage(imageUrl: article.urlToImage ?? ''),
        const _BottomGradient(),
        Positioned(
          top: 16,
          left: 16,
          right: 80,
          child: _TopBar(author: article.author),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: _BottomContent(article: article),
        ),
        const Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: _ScrollHint(),
        ),
      ],
    );
  }
}

// ─── Background Image ───────────────────────

class _BackgroundImage extends StatelessWidget {
  final String imageUrl;

  const _BackgroundImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(Icons.article_rounded, color: Colors.white24, size: 60),
        ),
      );
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFF1A1A2E),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white54),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: const Color(0xFF1A1A2E),
        child: const Center(
          child: Icon(Icons.broken_image, color: Colors.white38, size: 60),
        ),
      ),
    );
  }
}

// ─── Bottom gradient ────────────────────────

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [
            Color(0xE6000000),
            Color(0x00000000),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ────────────────────────────────

class _TopBar extends StatelessWidget {
  final String? author;

  const _TopBar({this.author});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.only(left: 4, right: 14, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.newspaper, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  author ?? 'News',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bottom Content ──────────────────────────

class _BottomContent extends StatelessWidget {
  final ArticleEntity article;

  const _BottomContent({required this.article});

  String _formatTimeAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          article.title ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            height: 1.3,
            shadows: [Shadow(blurRadius: 6, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          article.description ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
            height: 1.4,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _formatTimeAgo(article.publishedAt),
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Scroll Hint ─────────────────────────────

class _ScrollHint extends StatelessWidget {
  const _ScrollHint();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.keyboard_arrow_up, color: Colors.white38, size: 20),
      ],
    );
  }
}
