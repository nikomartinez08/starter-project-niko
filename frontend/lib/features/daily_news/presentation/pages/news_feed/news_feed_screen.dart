import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../favorites/domain/entities/favorite_article.dart';
import '../../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../../favorites/presentation/bloc/favorites_event.dart';
import '../../../domain/entities/draft.dart';

// ─────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────

class NewsModel {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String timeAgo;

  const NewsModel({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.timeAgo,
  });
}

// ─────────────────────────────────────────────
// MOCK DATA
// ─────────────────────────────────────────────

final List<NewsModel> _mockNews = [
  const NewsModel(
    title:
        'Inteligencia Artificial supera a humanos en diagnósticos médicos con un 98% de precisión',
    subtitle:
        'Un nuevo modelo de IA desarrollado en MIT logra resultados históricos en detección temprana de cáncer.',
    imageUrl:
        'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800&q=80',
    timeAgo: 'Hace 2h',
  ),
  const NewsModel(
    title:
        'La NASA anuncia el descubrimiento de agua líquida en la superficie de Marte',
    subtitle:
        'El hallazgo podría cambiar para siempre la forma en que entendemos la vida extraterrestre.',
    imageUrl:
        'https://images.unsplash.com/photo-1614726365952-510103b1bbb4?w=800&q=80',
    timeAgo: 'Hace 4h',
  ),
  const NewsModel(
    title:
        'Mercados globales alcanzan máximos históricos tras acuerdo económico entre EE.UU. y China',
    subtitle:
        'El Dow Jones sube un 3.5% en un solo día, el mayor incremento desde 2020.',
    imageUrl:
        'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800&q=80',
    timeAgo: 'Hace 6h',
  ),
  const NewsModel(
    title:
        'Científicos logran revertir el envejecimiento celular en humanos por primera vez',
    subtitle:
        'Un ensayo clínico pionero consigue rejuvenecer células hasta 25 años usando terapia génica avanzada.',
    imageUrl:
        'https://images.unsplash.com/photo-1532187863486-abf9dbad1b69?w=800&q=80',
    timeAgo: 'Hace 8h',
  ),
  const NewsModel(
    title:
        'Tesla presenta su nuevo modelo con autonomía de 1.000 km y carga en menos de 10 minutos',
    subtitle:
        'El vehículo eléctrico promete revolucionar la industria automotriz mundial con tecnología de baterías sólidas.',
    imageUrl:
        'https://images.unsplash.com/photo-1593941707882-a5bba14938c7?w=800&q=80',
    timeAgo: 'Hace 10h',
  ),
];

// ─────────────────────────────────────────────
// NEWS FEED CONTENT (embeddable, no Scaffold)
// Vertical scroll = TikTok, Horizontal swipe = Tinder
// ─────────────────────────────────────────────

class NewsFeedContent extends StatefulWidget {
  const NewsFeedContent({Key? key}) : super(key: key);

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

  void _goToNextPage() {
    final nextPage = (_pageController.page?.round() ?? 0) + 1;
    if (nextPage < _mockNews.length) {
      _pageController.jumpToPage(nextPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: _mockNews.length,
          itemBuilder: (context, index) {
            return _SwipeableCard(
              news: _mockNews[index],
              onSwiped: _goToNextPage,
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
  final NewsModel news;
  final VoidCallback? onSwiped;

  const _SwipeableCard({required this.news, this.onSwiped});

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
    final news = widget.news;
    final favorite = FavoriteArticleEntity(
      externalId: news.imageUrl,
      author: 'News Feed',
      title: news.title,
      description: news.subtitle,
      url: news.imageUrl,
      urlToImage: news.imageUrl,
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
    final news = widget.news;
    final draft = DraftEntity(
      title: news.title,
      content: news.subtitle,
      imagePath: news.imageUrl,
      author: 'News Feed',
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewsDetailScreen(news: widget.news),
                ),
              );
            },
            child: Transform.translate(
              offset: _dragOffset,
              child: Transform.rotate(
                angle: _dragAngle,
                child: Stack(
                fit: StackFit.expand,
                children: [
                  NewsCard(news: widget.news),

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
// NEWS CARD (full-screen item)
// ─────────────────────────────────────────────

class NewsCard extends StatelessWidget {
  final NewsModel news;

  const NewsCard({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _BackgroundImage(imageUrl: news.imageUrl),
        const _BottomGradient(),
        const Positioned(
          top: 16,
          left: 16,
          child: _TopBar(),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: _BottomContent(news: news),
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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: ClipOval(
            child: Container(
              color: Colors.black,
              child: const Icon(Icons.newspaper, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'News',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            shadows: [Shadow(blurRadius: 4, color: Colors.black)],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'BREAKING',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Content ──────────────────────────

class _BottomContent extends StatelessWidget {
  final NewsModel news;

  const _BottomContent({required this.news});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          news.title,
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
          news.subtitle,
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
              news.timeAgo,
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

// ─────────────────────────────────────────────
// NEWS DETAIL SCREEN
// ─────────────────────────────────────────────

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Stack(
                children: [
                  SizedBox(
                    height: 320,
                    width: double.infinity,
                    child: Image.network(
                      news.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1A1A2E),
                        child: const Icon(Icons.broken_image,
                            color: Colors.white38, size: 60),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xFF0D0D0D),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'BREAKING',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          news.timeAgo,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      news.subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 20),
                    ..._buildBodyParagraphs(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBodyParagraphs() {
    const paragraphs = [
      'Los investigadores y expertos del sector han confirmado que este avance representa uno de los hitos más significativos de la última década. El impacto potencial sobre millones de personas alrededor del mundo podría ser inconmensurable.',
      'Fuentes cercanas al proyecto indicaron que el desarrollo llevó más de cinco años de investigación colaborativa entre instituciones de primer nivel en Europa, Asia y América del Norte.',
      'Los primeros resultados experimentales superaron ampliamente las expectativas iniciales del equipo. La comunidad científica ya debate las implicaciones a largo plazo de este descubrimiento.',
      'Los organismos reguladores internacionales han comenzado a revisar los datos preliminares con el objetivo de emitir una respuesta oficial en las próximas semanas. Se espera que los resultados completos se publiquen en una revista científica de alto impacto.',
      'Este hito abre la puerta a una nueva era de posibilidades. Los próximos meses serán cruciales para determinar cómo esta tecnología —o descubrimiento— se integrará al tejido social, económico y tecnológico global.',
    ];

    return paragraphs.map((p) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          p,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 15,
            height: 1.7,
          ),
        ),
      );
    }).toList();
  }
}
