import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../domain/entities/profile_entities.dart';
import '../../../daily_news/domain/entities/article.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  // Dark theme colors matching home feed
  static const Color kBackground = Color(0xFF000000);
  static const Color kSurface = Color(0xFF1C1C1E);
  static const Color kBorder = Color(0xFF2C2C2E);
  static const Color kPrimaryText = Color(0xFFFFFFFF);
  static const Color kSecondaryText = Color(0xFF8E8E93);
  static const Color kAccent = Color(0xFF636366);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: kSecondaryText),
              ),
            );
          }
          if (state is ProfileLoaded) {
            return _buildContent(context, state.profile);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, UserProfileDataEntity profile) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(RefreshProfileEvent());
        // Wait a bit to ensure the refresh feels responsive, 
        // as the bloc might not emit a new state if data is same or fails.
        // A better way would be using a Completer passed in the event.
        await Future.delayed(const Duration(seconds: 1)); 
      },
      color: Colors.white,
      backgroundColor: kSurface,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(context, profile),
              const SizedBox(height: 24),
              _buildStats(profile),
              const SizedBox(height: 32),
              _buildArticlesSection(context, profile),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfileDataEntity profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              GestureDetector(
                onTap: () => _showEditProfileDialog(context, profile),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                  ),
                  child: const Icon(Icons.edit_outlined, color: kSecondaryText, size: 18),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kBorder, width: 2),
            ),
            child: CircleAvatar(
              radius: 48,
              backgroundColor: kBackground,
              backgroundImage: profile.photoUrl != null
                  ? NetworkImage(profile.photoUrl!)
                  : null,
              child: profile.photoUrl == null
                  ? const Icon(Icons.person, size: 48, color: kAccent)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kPrimaryText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.title ?? "Nuevo usuario",
            style: const TextStyle(
              fontSize: 14,
              color: kSecondaryText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile.email,
            style: const TextStyle(
              fontSize: 13,
              color: kAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(UserProfileDataEntity profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            profile.posts.length.toString(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kPrimaryText,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Artículos publicados",
            style: TextStyle(
              fontSize: 14,
              color: kSecondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticlesSection(BuildContext context, UserProfileDataEntity profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Mis artículos",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kPrimaryText,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 16),
        if (profile.posts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              children: const [
                Icon(Icons.article_outlined, size: 40, color: kAccent),
                SizedBox(height: 12),
                Text(
                  "No hay artículos aún",
                  style: TextStyle(color: kSecondaryText, fontSize: 15),
                ),
                SizedBox(height: 4),
                Text(
                  "Tus publicaciones aparecerán aquí",
                  style: TextStyle(color: kAccent, fontSize: 13),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.posts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildArticleCard(context, profile.posts[index], profile.name);
            },
          ),
      ],
    );
  }

  Widget _buildArticleCard(BuildContext context, UserPostEntity post, String authorName) {
    return GestureDetector(
      onTap: () {
        final article = ArticleEntity(
          id: null,
          author: authorName,
          title: post.title,
          description: post.description ?? post.content,
          urlToImage: post.urlToImage,
          publishedAt: post.createdAt.toString(),
          content: post.content,
        );
        Navigator.pushNamed(context, '/ArticleDetails', arguments: article);
      },
      child: Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.urlToImage != null)
              Stack(
                children: [
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      post.urlToImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: kBackground,
                        child: const Center(
                          child: Icon(Icons.image_outlined, color: kAccent, size: 32),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            kSurface,
                            kSurface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: kPrimaryText,
                      height: 1.3,
                    ),
                  ),
                  if (post.description != null || post.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      post.description ?? post.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: kSecondaryText,
                        height: 1.4,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _formatDate(post.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: kAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
    if (diff.inHours < 24) return 'hace ${diff.inHours}h';
    if (diff.inDays < 7) return 'hace ${diff.inDays}d';
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showEditProfileDialog(BuildContext context, UserProfileDataEntity profile) {
    final profileBloc = context.read<ProfileBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider.value(
        value: profileBloc,
        child: _EditProfileDialog(profile: profile),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final UserProfileDataEntity profile;

  const _EditProfileDialog({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

  static const Color kBackground = ProfilePage.kBackground;
  static const Color kSurface = ProfilePage.kSurface;
  static const Color kBorder = ProfilePage.kBorder;
  static const Color kPrimaryText = ProfilePage.kPrimaryText;
  static const Color kSecondaryText = ProfilePage.kSecondaryText;
  static const Color kAccent = ProfilePage.kAccent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _titleController = TextEditingController(text: widget.profile.title ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;
    try {
      if (!await _imageFile!.exists()) {
        throw Exception('El archivo local no existe');
      }

      final userId = widget.profile.uid;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final path = 'user_profiles/$fileName';

      final supabase = Supabase.instance.client;

      await supabase.storage.from('images').upload(
        path,
        _imageFile!,
        fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false),
      );

      final url = supabase.storage.from('images').getPublicUrl(path);
      return url;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _save() async {
    setState(() => _isUploading = true);

    String? photoUrl;
    if (_imageFile != null) {
      photoUrl = await _uploadImage();
      if (photoUrl == null) {
        setState(() => _isUploading = false);
        return;
      }
    }

    if (mounted) {
      context.read<ProfileBloc>().add(
            UpdateProfileEvent(
              name: _nameController.text,
              title: _titleController.text,
              photoUrl: photoUrl,
            ),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Editar Perfil",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kPrimaryText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: kBorder, width: 2),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (widget.profile.photoUrl != null
                                ? Image.network(widget.profile.photoUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.person, size: 48, color: kAccent)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: kSurface, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: kBackground, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildTextField(
              controller: _nameController,
              label: "Nombre completo",
              hint: "Ej. Juan Pérez",
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              label: "Cargo / Título",
              hint: "Ej. Editor Senior",
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: kSecondaryText,
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text("Guardar", style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kSecondaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: kPrimaryText, fontSize: 15),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kAccent.withValues(alpha: 0.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: kBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
