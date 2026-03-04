import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/draft/draft_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/upload/upload_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/markdown_toolbar.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/markdown_preview.dart';

class UploadArticlePage extends StatefulWidget {
  final DraftEntity? draft;

  const UploadArticlePage({Key? key, this.draft}) : super(key: key);

  @override
  State<UploadArticlePage> createState() => _UploadArticlePageState();
}

class _UploadArticlePageState extends State<UploadArticlePage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();
  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  bool _isPreviewMode = false;
  int? _currentDraftId;
  bool _hasUnsavedChanges = false;
  Timer? _autoSaveTimer;
  DateTime? _lastSaved;

  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);
  static const _hintText = Color(0xFF3A3A3C);

  @override
  void initState() {
    super.initState();
    if (widget.draft != null) {
      _titleController.text = widget.draft!.title ?? '';
      _authorController.text = widget.draft!.author ?? '';
      _contentController.text = widget.draft!.content ?? '';
      _selectedImagePath = widget.draft!.imagePath;
      _currentDraftId = widget.draft!.id;
    }

    _titleController.addListener(_onContentChanged);
    _authorController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_hasUnsavedChanges && mounted) {
        _saveDraft(context, showSnackBar: false);
      }
    });
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _authorController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImagePath = image.path;
        _hasUnsavedChanges = true;
      });
    }
  }

  Future<void> _saveDraft(BuildContext context, {bool showSnackBar = true}) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      if (showSnackBar) _showToast('Nothing to save');
      return;
    }

    final now = DateTime.now().toIso8601String();
    final draft = DraftEntity(
      id: _currentDraftId,
      author: _authorController.text.trim(),
      title: title,
      content: content,
      imagePath: _selectedImagePath,
      createdAt: widget.draft?.createdAt ?? now,
      updatedAt: now,
    );

    final draftCubit = context.read<DraftCubit>();
    if (_currentDraftId != null) {
      await draftCubit.updateDraft(draft);
    } else {
      final id = await draftCubit.saveDraft(draft);
      if (id > 0) _currentDraftId = id;
    }

    setState(() {
      _hasUnsavedChanges = false;
      _lastSaved = DateTime.now();
    });

    if (showSnackBar && context.mounted) _showToast('Draft saved');
  }

  void _publish(BuildContext context) {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty ||
        _selectedImagePath == null) {
      _showToast('Add a title, content and cover image to publish');
      return;
    }
    context.read<UploadArticleCubit>().uploadArticle(
          author: _authorController.text,
          title: _titleController.text,
          content: _contentController.text,
          urlToImage: _selectedImagePath!,
        );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _SheetTile(
              icon: _isPreviewMode ? Icons.edit_outlined : Icons.visibility_outlined,
              label: _isPreviewMode ? 'Back to Edit' : 'Preview',
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _isPreviewMode = !_isPreviewMode);
              },
            ),
            _SheetTile(
              icon: Icons.save_outlined,
              label: 'Save Draft',
              trailing: _hasUnsavedChanges
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                _saveDraft(context);
              },
            ),
            _SheetTile(
              icon: Icons.folder_outlined,
              label: 'My Drafts',
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.pushNamed(context, '/Drafts');
                if (result is DraftEntity && mounted) {
                  setState(() {
                    _titleController.text = result.title ?? '';
                    _authorController.text = result.author ?? '';
                    _contentController.text = result.content ?? '';
                    _selectedImagePath = result.imagePath;
                    _currentDraftId = result.id;
                    _hasUnsavedChanges = false;
                  });
                }
              },
            ),
            _SheetTile(
              icon: Icons.send_rounded,
              label: 'Publish Article',
              onTap: () {
                Navigator.pop(ctx);
                _publish(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: BlocConsumer<UploadArticleCubit, UploadArticleState>(
        listener: (context, state) {
          if (state is UploadArticleSuccess) {
            if (_currentDraftId != null) {
              context.read<DraftCubit>().deleteDraft(_currentDraftId!);
            }
            _showToast('Article published!');
            Navigator.of(context).pop();
          } else if (state is UploadArticleError) {
            _showToast(state.error ?? 'Something went wrong');
          }
        },
        builder: (context, state) {
          final isLoading = state is UploadArticleLoading;
          return SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isLoading),
                const Divider(height: 1, thickness: 1, color: _border),
                Expanded(
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : _isPreviewMode
                          ? _buildPreview()
                          : _buildEditor(),
                ),
                if (!_isPreviewMode)
                  MarkdownToolbar(
                    controller: _contentController,
                    onChanged: () => setState(() {}),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentDraftId != null ? 'Edit Draft' : 'New Article',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                if (_lastSaved != null)
                  Text(
                    'Saved ${_timeAgo(_lastSaved!)}',
                    style: const TextStyle(color: _secondaryText, fontSize: 11),
                  ),
              ],
            ),
          ),
          if (_hasUnsavedChanges)
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 14),
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          GestureDetector(
            onTap: isLoading ? null : () => _showActionsSheet(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_horiz, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCoverSection(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    letterSpacing: -0.8,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(
                      color: _hintText,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.8,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  maxLines: null,
                  keyboardAppearance: Brightness.dark,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 10),
                // Author
                Row(
                  children: [
                    const Text(
                      'by ',
                      style: TextStyle(color: _hintText, fontSize: 15),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _authorController,
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'your name',
                          hintStyle: TextStyle(color: _hintText, fontSize: 15),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        keyboardAppearance: Brightness.dark,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(height: 1, color: _border),
                const SizedBox(height: 22),
                // Content
                TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.8,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tell your story...',
                    hintStyle: TextStyle(
                      color: _hintText,
                      fontSize: 16,
                      height: 1.8,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  maxLines: null,
                  minLines: 16,
                  keyboardType: TextInputType.multiline,
                  keyboardAppearance: Brightness.dark,
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverSection() {
    if (_selectedImagePath != null) {
      return Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 220,
            child: _buildImageWidget(_selectedImagePath!, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [_bg, Colors.transparent],
                  stops: [0.0, 0.45],
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Row(
              children: [
                _coverActionButton(icon: Icons.photo_camera_outlined, onTap: _pickImage),
                const SizedBox(width: 8),
                _coverActionButton(
                  icon: Icons.close_rounded,
                  onTap: () => setState(() {
                    _selectedImagePath = null;
                    _hasUnsavedChanges = true;
                  }),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 220,
        color: _surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[700], size: 36),
            const SizedBox(height: 10),
            Text(
              'Add cover image',
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coverActionButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedImagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildImageWidget(_selectedImagePath!, height: 200),
            ),
            const SizedBox(height: 22),
          ],
          if (_titleController.text.isNotEmpty)
            Text(
              _titleController.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                height: 1.3,
                letterSpacing: -0.8,
              ),
            ),
          if (_authorController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'by ${_authorController.text}',
              style: const TextStyle(color: _secondaryText, fontSize: 15),
            ),
          ],
          const SizedBox(height: 20),
          Container(height: 1, color: _border),
          const SizedBox(height: 8),
          MarkdownPreview(data: _contentController.text),
        ],
      ),
    );
  }

  bool _isUrl(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  Widget _buildImageWidget(String path, {BoxFit fit = BoxFit.cover, double? height}) {
    if (_isUrl(path)) {
      return Image.network(path, fit: fit, height: height, width: double.infinity);
    }
    return Image.file(File(path), fit: fit, height: height, width: double.infinity);
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: trailing,
    );
  }
}
