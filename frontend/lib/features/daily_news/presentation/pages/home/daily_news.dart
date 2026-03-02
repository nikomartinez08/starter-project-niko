import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';

import '../../../domain/entities/article.dart';
import '../../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../../profile/presentation/bloc/profile_event.dart';
import '../../../../profile/presentation/pages/profile_page.dart';
import '../../../../../../injection_container.dart';

class DailyNews extends StatefulWidget {
  const DailyNews({Key? key}) : super(key: key);

  @override
  State<DailyNews> createState() => _DailyNewsState();
}

class _DailyNewsState extends State<DailyNews> {
  int _currentIndex = 0;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Technology',
    'Politics',
    'Sports',
    'Finance'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _currentIndex == 0 ? _buildHomeBody() : _buildProfileBody(),
      extendBody: true,
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Daily News',
        style: TextStyle(color: Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/UploadArticle'),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.add, color: Colors.black),
          ),
        ),
        GestureDetector(
          onTap: () => _onShowFavoritesViewTapped(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.favorite, color: Colors.red),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 20),
      child: SizedBox(
        height: 65,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // La píldora flotante
            Container(
              height: 65,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Inicio
                  _buildNavItem(
                    icon: Icons.home,
                    label: 'Inicio',
                    index: 0,
                  ),
                  // Espacio para el botón central
                  const SizedBox(width: 64),
                  // Perfil
                  _buildNavItem(
                    icon: Icons.person,
                    label: 'Perfil',
                    index: 1,
                  ),
                ],
              ),
            ),
            // Botón central TikTok elevado
            Positioned(
              top: -22,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/NewsFeed'),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 14,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? Colors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
      builder: (context, state) {
        if (state is RemoteArticlesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is RemoteArticlesError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.grey),
                const SizedBox(height: 10),
                Text("Error: ${state.error?.message ?? 'Unknown error'}"),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<RemoteArticlesBloc>().add(const GetArticles());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          );
        }
        if (state is RemoteArticlesDone) {
          if (state.articles == null || state.articles!.isEmpty) {
            return Column(
              children: [
                _buildCategoryChips(),
                const Expanded(child: Center(child: Text("No articles found"))),
              ],
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildCategoryChips(),
              ),
              SliverToBoxAdapter(
                child: _buildBreakingNews(context, state.articles![0]),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildArticleGridItem(
                          context, state.articles![index + 1]);
                    },
                    childCount: state.articles!.length - 1,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75, // Adjust this ratio as needed
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                  if (category == 'All') {
                    context.read<RemoteArticlesBloc>().add(const ResetFilter());
                  } else {
                    context
                        .read<RemoteArticlesBloc>()
                        .add(FilterArticles(category));
                  }
                }
              },
              selectedColor: Colors.black,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildArticleGridItem(BuildContext context, ArticleEntity article) {
    return GestureDetector(
      onTap: () => _onArticlePressed(context, article),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: _buildGridImage(article),
              ),
            ),
            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Badge/Category
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "NEWS", // Placeholder for category
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            article.publishedAt ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    // Title
                    Text(
                      article.title ?? 'No Title',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    // Footer with options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            article.author ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.more_horiz,
                            size: 16, color: Colors.grey),
                      ],
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

  Widget _buildProfileBody() {
    return BlocProvider<ProfileBloc>(
      create: (context) => sl()..add(GetProfileEvent()),
      child: const ProfilePage(),
    );
  }

  Widget _buildBreakingNews(BuildContext context, ArticleEntity article) {
    return GestureDetector(
      onTap: () => _onArticlePressed(context, article),
      child: _buildBreakingNewsContent(context, article),
    );
  }

  Widget _buildBreakingNewsContent(
      BuildContext context, ArticleEntity article) {
    final String imageUrl = article.urlToImage ?? '';
    final bool isImageValid = imageUrl.isNotEmpty && imageUrl != kDefaultImage;

    if (isImageValid) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) =>
            _buildBreakingNewsContainer(context, article, imageProvider),
        placeholder: (context, url) => _buildBreakingNewsContainer(
            context, article, null,
            isLoading: true),
        errorWidget: (context, url, error) =>
            _buildBreakingNewsContainer(context, article, null),
      );
    } else {
      return _buildBreakingNewsContainer(context, article, null);
    }
  }

  Widget _buildBreakingNewsContainer(
      BuildContext context, ArticleEntity article, ImageProvider? imageProvider,
      {bool isLoading = false}) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
        color: isLoading ? Colors.grey[300] : Colors.grey,
      ),
      child: Stack(
        children: [
          if (imageProvider == null && !isLoading)
            const Center(
                child:
                    Icon(Icons.broken_image, size: 50, color: Colors.white54)),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "BREAKING",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  article.title ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Text(
                  article.publishedAt ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridImage(ArticleEntity article) {
    final String imageUrl = article.urlToImage ?? '';
    // Check if URL is valid and not the broken default
    final bool isImageValid = imageUrl.isNotEmpty &&
        imageUrl != kDefaultImage &&
        Uri.tryParse(imageUrl)?.hasAbsolutePath == true;

    if (isImageValid) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CupertinoActivityIndicator()),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        color: Colors.grey[200],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
  }

  void _onShowFavoritesViewTapped(BuildContext context) {
    Navigator.pushNamed(context, '/Favorites');
  }
}
