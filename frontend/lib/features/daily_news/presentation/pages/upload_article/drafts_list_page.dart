import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/draft.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/draft/draft_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/draft/draft_state.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class DraftsListPage extends StatelessWidget {
  const DraftsListPage({Key? key}) : super(key: key);

  static const _bg = Color(0xFF0A0A0A);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DraftCubit>(
      create: (_) => sl<DraftCubit>()..loadDrafts(),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const Divider(height: 1, thickness: 1, color: _border),
              Expanded(
                child: BlocBuilder<DraftCubit, DraftState>(
                  builder: (context, state) {
                    if (state is DraftsLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      );
                    }
                    if (state is DraftError) {
                      return _buildError(state.message);
                    }
                    if (state is DraftsLoaded && state.drafts.isNotEmpty) {
                      return _buildList(context, state.drafts);
                    }
                    return _buildEmpty();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          const Text(
            'My Drafts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, size: 56, color: Colors.grey[800]),
          const SizedBox(height: 16),
          const Text(
            'No drafts yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start writing and save your work here',
            style: TextStyle(color: _secondaryText, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 44, color: Colors.red[400]),
          const SizedBox(height: 14),
          Text(message, style: const TextStyle(color: _secondaryText)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, List<DraftEntity> drafts) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: drafts.length,
      itemBuilder: (context, index) {
        return _DraftCard(
          draft: drafts[index],
          onTap: () => Navigator.pop(context, drafts[index]),
          onDelete: () {
            if (drafts[index].id != null) {
              context.read<DraftCubit>().deleteDraft(drafts[index].id!);
            }
          },
        );
      },
    );
  }
}

class _DraftCard extends StatelessWidget {
  final DraftEntity draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static const _surface = Color(0xFF1C1C1E);
  static const _border = Color(0xFF2C2C2E);
  static const _secondaryText = Color(0xFF8E8E93);

  const _DraftCard({
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(draft.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 24),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: _surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Draft', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This draft will be permanently deleted.',
            style: TextStyle(color: _secondaryText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel', style: TextStyle(color: Colors.grey[500])),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                draft.title?.isNotEmpty == true ? draft.title! : 'Untitled',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              // Content preview
              if (draft.content?.isNotEmpty == true) ...[
                const SizedBox(height: 6),
                Text(
                  draft.content!.replaceAll(RegExp(r'[#*_~`>\[\]!-]'), '').trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              // Footer
              Row(
                children: [
                  if (draft.author?.isNotEmpty == true) ...[
                    Text(
                      draft.author!,
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text('·', style: TextStyle(color: Colors.grey[700])),
                    ),
                  ],
                  Text(
                    _formatDate(draft.updatedAt),
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right_rounded, color: Colors.grey[700], size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
