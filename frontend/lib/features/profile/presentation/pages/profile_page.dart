import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile_entities.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CupertinoActivityIndicator(color: Colors.white),
            );
          }
          if (state is ProfileError) {
            if (state.message.contains('User not authenticated')) {
              return _buildUnauthenticatedView();
            }
            return Center(
              child: Text(state.message, style: const TextStyle(color: _secondaryText)),
            );
          }
          if (state is ProfileLoaded) {
            return _buildProfileView(context, state.profile);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 56, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'Not signed in',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sign in to view your profile',
            style: TextStyle(color: _secondaryText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfileDataEntity profile) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 28),
            // Avatar
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _surface,
                border: Border.all(color: _border, width: 2),
              ),
              child: const Icon(Icons.person_rounded, size: 44, color: _secondaryText),
            ),
            const SizedBox(height: 12),
            // Name
            Text(
              profile.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              profile.email,
              style: const TextStyle(color: _secondaryText, fontSize: 13),
            ),
            const SizedBox(height: 24),
            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStat('Articles', profile.posts.length.toString()),
                _buildStatDivider(),
                _buildStat('Followers', profile.followersCount.toString()),
                _buildStatDivider(),
                _buildStat('Following', profile.followingCount.toString()),
              ],
            ),
            const SizedBox(height: 20),
            // Quick links
            _buildQuickLinks(context),
            const SizedBox(height: 20),
            // Divider
            const Divider(height: 1, thickness: 1, color: _border),
            // Tabs
            const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: _secondaryText,
              indicatorColor: Colors.white,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(text: 'Publicaciones'),
                Tab(text: 'Información'),
              ],
            ),
            const Divider(height: 1, thickness: 1, color: _border),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPostsTab(profile.posts),
                  _buildInfoTab(profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: _secondaryText, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 28, color: _border);
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _QuickLinkButton(
              icon: Icons.edit_note_rounded,
              label: 'My Articles',
              onTap: () => Navigator.pushNamed(context, '/MyArticles'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickLinkButton(
              icon: Icons.bookmark_rounded,
              label: 'Saved',
              onTap: () => Navigator.pushNamed(context, '/Favorites'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(List<UserPostEntity> posts) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 44, color: Colors.grey[800]),
            const SizedBox(height: 14),
            const Text(
              'No posts yet',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: posts.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
      itemBuilder: (context, index) {
        final post = posts[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.createdAt.toString().split(' ')[0],
                style: const TextStyle(color: _secondaryText, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoTab(UserProfileDataEntity profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        _InfoRow(label: 'User ID', value: profile.uid),
        const Divider(height: 1, color: _border),
        _InfoRow(label: 'Email', value: profile.email),
        const Divider(height: 1, color: _border),
        _InfoRow(label: 'Name', value: profile.name),
      ],
    );
  }
}

class _QuickLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);

  const _QuickLinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
