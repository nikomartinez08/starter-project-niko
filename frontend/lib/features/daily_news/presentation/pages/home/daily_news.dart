import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

import '../../../domain/entities/article.dart';
import '../../bloc/article/local/local_article_bloc.dart';
import '../../bloc/article/local/local_article_event.dart';
import '../../bloc/article/local/local_article_state.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../profile/presentation/bloc/profile_event.dart';
import '../../../../profile/presentation/pages/profile_page.dart';
import '../../../../settings/presentation/pages/settings_page.dart';
import '../news_feed/news_feed_screen.dart';
import '../../../../../../injection_container.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final List<String> _categories = ['All', 'Technology', 'Politics', 'Sports', 'Finance'];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late final LocalArticleBloc _localArticleBloc;
  Set<String> _savedTitles = {};

  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _localArticleBloc = sl<LocalArticleBloc>()..add(const GetSavedArticles());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _localArticleBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<RemoteArticlesBloc>().add(const LoadMoreArticles());
    }
  }

  List<ArticleEntity> _filterOutSaved(List<ArticleEntity> articles) {
    if (_savedTitles.isEmpty) return articles;
    return articles.where((a) => !_savedTitles.contains(a.title)).toList();
  }

  void _refreshSavedArticles() {
    _localArticleBloc.add(const GetSavedArticles());
  }

  @override
  Widget build(BuildContext context) {
    final bool isFeedTab = _currentIndex == 1;
    return BlocProvider.value(
      value: _localArticleBloc,
      child: BlocListener<LocalArticleBloc, LocalArticlesState>(
        listener: (context, state) {
          if (state is LocalArticlesDone) {
            setState(() {
              _savedTitles = (state.articles ?? [])
                  .map((a) => a.title)
                  .whereType<String>()
                  .toSet();
            });
          }
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: isFeedTab ? null : _buildAppBar(context),
            backgroundColor: Colors.black,
            extendBody: true,
            body: _currentIndex == 0
                ? _buildHomeBody()
                : _currentIndex == 1
                    ? NewsFeedContent(savedTitles: _savedTitles)
                    : _buildProfileBody(),
            floatingActionButton: isFeedTab
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: FloatingActionButton(
                      onPressed: () => Navigator.pushNamed(context, '/BroadcasterScreen'),
                      backgroundColor: Colors.red,
                      child: const Icon(Icons.videocam_rounded, color: Colors.white),
                    ),
                  )
                : null,
            bottomNavigationBar: _buildBottomNavBar(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      titleSpacing: 16,
      leading: (_currentIndex == 0 || _currentIndex == 2)
          ? IconButton(
              icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 26),
              onPressed: () => SettingsModal.show(context),
              splashRadius: 22,
            )
          : null,
      title: Text(
        _currentIndex == 2 ? 'Profile' : 'Daily News',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
      actions: _currentIndex == 2
          ? [const SizedBox(width: 16)]
          : [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                onPressed: () => Navigator.pushNamed(context, '/UploadArticle'),
                splashRadius: 22,
              ),
              IconButton(
                icon: const Icon(Icons.favorite_rounded, color: Color(0xFFFF3B5C), size: 22),
                onPressed: () => _onShowFavoritesViewTapped(context),
                splashRadius: 22,
              ),
              const SizedBox(width: 4),
            ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 20),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Inicio', index: 0),
            _buildNavItem(icon: Icons.play_circle_filled_rounded, label: 'Feed', index: 1),
            _buildNavItem(icon: Icons.person_rounded, label: 'Perfil', index: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ArticleEntity> _filterBySearch(List<ArticleEntity> articles) {
    if (_searchQuery.isEmpty) return articles;
    final q = _searchQuery.toLowerCase();
    return articles.where((a) {
      final title = (a.title ?? '').toLowerCase();
      final author = (a.author ?? '').toLowerCase();
      final desc = (a.description ?? '').toLowerCase();
      return title.contains(q) || author.contains(q) || desc.contains(q);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search articles...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 15),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[600], size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  child: Icon(Icons.close_rounded, color: Colors.grey[600], size: 20),
                )
              : null,
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white24),
          ),
        ),
        keyboardAppearance: Brightness.dark,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildHomeBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        final List<Widget> slivers = [
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildCategoryChips()),
        ];

        if (state is RemoteArticlesLoading) {
          slivers.add(
            const SliverFillRemaining(
              child: Center(
                child: CupertinoActivityIndicator(color: Colors.white),
              ),
            ),
          );
        } else if (state is RemoteArticlesError) {
          slivers.add(
            SliverFillRemaining(
              child: Center(
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
              ),
            ),
          );
        } else if (state is RemoteArticlesDone) {
          final articles = _filterOutSaved(_filterBySearch(state.articles ?? []));
          if (articles.isEmpty) {
            slivers.add(
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    _searchQuery.isNotEmpty ? 'No results for "$_searchQuery"' : 'No articles found',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
            );
          } else {
            slivers.add(
              SliverToBoxAdapter(
                child: _buildHeroCard(context, articles[0]),
              ),
            );
            slivers.add(SliverToBoxAdapter(child: _buildSectionHeader('Top Stories')));
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildGridCard(context, articles[index + 1]),
                    childCount: articles.length - 1,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              ),
            );
            // Loading more indicator or end-of-list spacer
            if (state is RemoteArticlesLoadingMore) {
              slivers.add(
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CupertinoActivityIndicator(color: Colors.white),
                    ),
                  ),
                ),
              );
            }
            // Bottom padding for nav bar
            slivers.add(
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            );
          }
        } else {
          slivers.add(const SliverToBoxAdapter(child: SizedBox()));
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<RemoteArticlesBloc>().add(const RefreshArticles());
            // Wait for the bloc to emit a non-loading state
            await context.read<RemoteArticlesBloc>().stream.firstWhere(
              (s) => s is RemoteArticlesDone || s is RemoteArticlesError,
            );
          },
          color: Colors.white,
          backgroundColor: _surface,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: slivers,
          ),
        );
      },
    );
  }

  // ── Category chips ──────────────────────────────────────────────────────────

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category);
              if (category == 'All') {
                context.read<RemoteArticlesBloc>().add(const ResetFilter());
              } else {
                context.read<RemoteArticlesBloc>().add(FilterArticles(category));
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.white : const Color(0xFF3A3A3C),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey[500],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Hero / Breaking news card ────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, ArticleEntity article) {
    final String imageUrl = article.urlToImage ?? '';
    final bool hasImage = imageUrl.isNotEmpty &&
        imageUrl != kDefaultImage &&
        Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

    return GestureDetector(
      onTap: () => _onArticlePressed(context, article),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: _surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              if (hasImage)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: _border),
                  errorWidget: (_, __, ___) => Container(
                    color: _surface,
                    child: const Icon(Icons.broken_image, color: Colors.white24, size: 48),
                  ),
                )
              else
                Container(
                  color: _surface,
                  child: const Icon(Icons.image, color: Colors.white24, size: 48),
                ),

              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.92),
                      Colors.black.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        'TOP STORY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title
                    Text(
                      article.title ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        letterSpacing: -0.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Author + date row
                    Row(
                      children: [
                        if ((article.author ?? '').isNotEmpty) ...[
                          Flexible(
                            child: Text(
                              article.author!,
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('·', style: TextStyle(color: Colors.white38)),
                          ),
                        ],
                        Text(
                          _formatDate(article.publishedAt),
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section header ───────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  // ── Grid card ────────────────────────────────────────────────────────────────

  Widget _buildGridCard(BuildContext context, ArticleEntity article) {
    return GestureDetector(
      onTap: () => _onArticlePressed(context, article),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with gradient
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildGridImage(article),
                    // Subtle bottom fade on image
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Text content
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        article.title ?? 'No Title',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.35,
                          letterSpacing: -0.2,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              article.author ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF8E8E93),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatDate(article.publishedAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF636366),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridImage(ArticleEntity article) {
    final String imageUrl = article.urlToImage ?? '';
    final bool isImageValid = imageUrl.isNotEmpty &&
        imageUrl != kDefaultImage &&
        Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

    if (isImageValid) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: _border),
        errorWidget: (_, __, ___) => Container(
          color: _border,
          child: Icon(Icons.broken_image_rounded, color: Colors.grey[700]),
        ),
      );
    }
    return Container(
      width: double.infinity,
      color: _border,
      child: Icon(Icons.image_rounded, color: Colors.grey[700]),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${date.day}/${date.month}';
  }

  Widget _buildProfileBody() {
    return BlocProvider<ProfileBloc>(
      create: (context) => sl()..add(GetProfileEvent()),
      child: const ProfilePage(),
    );
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article).then((_) {
      _refreshSavedArticles();
    });
  }

  void _onShowFavoritesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/Favorites');
  }
}
