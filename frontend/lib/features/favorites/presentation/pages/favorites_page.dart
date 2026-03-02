import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_state.dart';
import '../bloc/favorites_event.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Saved Articles', style: TextStyle(color: Colors.black)),
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        if (state is FavoritesLoading) {
          return const Center(child: CupertinoActivityIndicator());
        }
        if (state is FavoritesError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is FavoritesEmpty) {
          return const Center(child: Text('No saved articles yet.'));
        }
        if (state is FavoritesLoaded) {
          return ListView.builder(
            itemCount: state.favorites.length,
            itemBuilder: (context, index) {
              final article = state.favorites[index];
              return ListTile(
                leading: article.urlToImage != null 
                    ? Image.network(article.urlToImage!, width: 100, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.error)) 
                    : const Icon(Icons.image),
                title: Text(article.title ?? 'No title', maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(article.publishedAt ?? '', maxLines: 1),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    context.read<FavoritesBloc>().add(ToggleFavoriteEvent(article));
                  },
                ),
                onTap: () {
                  // Navigate to article details (assuming you have a route)
                  Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
