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

  // Design Tokens - Modern Corporate Minimalism
  static const Color kBgColor = Color(0xFFF9FAFB);
  static const Color kContainerColor = Colors.white;
  static const Color kPrimaryText = Color(0xFF111827);
  static const Color kSecondaryText = Color(0xFF6B7280);
  static const Color kBorderColor = Color(0xFFE5E7EB);
  static const Color kLightGrayText = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: kPrimaryText,
              ),
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
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildHeader(context, profile),
                const SizedBox(height: 24),
                _buildMetrics(profile),
                const SizedBox(height: 40),
                const Text(
                  "Publicaciones",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryText,
                  ),
                ),
                const SizedBox(height: 20),
                _buildPublicationsList(profile),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfileDataEntity profile) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: kContainerColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kBorderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.edit_outlined, color: kSecondaryText),
                tooltip: 'Editar perfil',
                onPressed: () => _showEditProfileDialog(context, profile),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kBorderColor),
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    backgroundImage: profile.photoUrl != null
                        ? NetworkImage(profile.photoUrl!)
                        : const NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  profile.title ?? "Editor Senior",
                  style: const TextStyle(
                    fontSize: 14,
                    color: kSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProfileDataEntity profile) {
    // Capture the existing ProfileBloc to pass it to the dialog
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

  Widget _buildMetrics(UserProfileDataEntity profile) {
    return Container(
      height: 120, // Fixed height for consistency
      decoration: BoxDecoration(
         color: kContainerColor,
         borderRadius: BorderRadius.circular(8),
         border: Border.all(color: kBorderColor),
         boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Center and space items evenly
        children: [
          _buildMetricItem(profile.posts.length.toString(), "Publicaciones"),
          _buildMetricDivider(),
          _buildMetricItem(profile.followersCount.toString(), "Seguidores"),
          _buildMetricDivider(),
          _buildMetricItem(profile.followingCount.toString(), "Siguiendo"),
        ],
      ),
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      height: 40,
      width: 1,
      color: kBorderColor,
    );
  }

  Widget _buildMetricItem(String value, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: kPrimaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: kSecondaryText,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 20, 
          height: 1, 
          color: kBorderColor,
        ),
      ],
    );
  }

  Widget _buildPublicationsList(UserProfileDataEntity profile) {
    if (profile.posts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: kContainerColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kBorderColor),
        ),
        child: const Center(
          child: Text(
            "No hay publicaciones recientes",
            style: TextStyle(color: kSecondaryText),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: profile.posts.length,
      itemBuilder: (context, index) {
        return _buildPublicationItem(context, profile.posts[index], profile.name);
      },
    );
  }

  Widget _buildPublicationItem(BuildContext context, UserPostEntity post, String authorName) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Convert UserPostEntity to ArticleEntity for navigation
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
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kContainerColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: kBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (post.urlToImage != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(post.urlToImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.description ?? post.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: kSecondaryText,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _formatDate(post.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: kLightGrayText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
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
      // Use timestamp to ensure unique filename and avoid caching issues
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${userId}_$timestamp.jpg';
      final path = 'user_profiles/$fileName';
      
      debugPrint('Iniciando subida a Supabase: images/$path');

      final supabase = Supabase.instance.client;
      
      // Subir archivo al bucket 'images'
      await supabase.storage.from('images').upload(
        path,
        _imageFile!,
        fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: false
        ),
      );
      
      // Obtener la URL pública
      final url = supabase.storage.from('images').getPublicUrl(path);
      
      debugPrint('Subida exitosa. URL obtenida: $url');
      return url;

    } catch (e) {
      debugPrint('Error detallado uploading image to Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir imagen: $e'), 
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
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
        // Upload failed, stop saving
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
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Editar Perfil",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: ProfilePage.kPrimaryText,
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: ProfilePage.kBorderColor, width: 2),
                      ),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (widget.profile.photoUrl != null
                                ? Image.network(widget.profile.photoUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.person, size: 60, color: ProfilePage.kSecondaryText)),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
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
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isUploading ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: ProfilePage.kSecondaryText,
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isUploading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Guardar cambios"),
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
            color: ProfilePage.kPrimaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: ProfilePage.kSecondaryText.withOpacity(0.5)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ProfilePage.kBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ProfilePage.kBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

