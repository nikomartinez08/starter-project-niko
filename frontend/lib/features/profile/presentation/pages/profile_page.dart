import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile_entities.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }
          if (state is ProfileError) {
            // To mock ui if user isn't logged in, we can show a placeholder or error.
            if (state.message.contains('User not authenticated')) {
              return _buildUnauthenticatedView();
            }
            return Center(child: Text("Error: ${state.message}"));
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
    return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.person_off, size: 60, color: Colors.grey),
      SizedBox(height: 16),
      Text("Please log in to view your profile",
          style: TextStyle(fontSize: 16, color: Colors.grey)),
    ]));
  }

  Widget _buildProfileView(
      BuildContext context, UserProfileDataEntity profile) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const SizedBox(height: 20),
            // User Header Info
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              profile.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              profile.email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Posts', profile.posts.length.toString()),
                _buildStatColumn(
                    'Followers', profile.followersCount.toString()),
                _buildStatColumn(
                    'Following', profile.followingCount.toString()),
              ],
            ),
            const SizedBox(height: 20),
            const TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(text: "Publicaciones"),
                Tab(text: "Información"),
              ],
            ),
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

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildPostsTab(List<UserPostEntity> posts) {
    if (posts.isEmpty) {
      return const Center(
          child: Text("No posts available.",
              style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return ListTile(
          leading: const Icon(Icons.article),
          title:
              Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(post.createdAt.toString().split(' ')[0]),
        );
      },
    );
  }

  Widget _buildInfoTab(UserProfileDataEntity profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("UID"),
          subtitle: Text(profile.uid),
        ),
      ],
    );
  }
}
