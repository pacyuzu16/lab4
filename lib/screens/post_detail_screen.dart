import 'package:flutter/material.dart';
import '../models/post.dart';
import 'post_form_screen.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  // Tracks whether an edit was made so the list refreshes only when needed.
  bool _wasEdited = false;

  Future<void> _openEditForm() async {
    final edited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => PostFormScreen(post: widget.post)),
    );
    if (edited == true) setState(() => _wasEdited = true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      // Return _wasEdited so the list screen knows whether to refresh.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && result == null) {
          Navigator.of(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: Text('Post #${widget.post.id}'),
          leading: BackButton(
            onPressed: () => Navigator.pop(context, _wasEdited),
          ),
        ),

        // Edit FAB
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openEditForm,
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit Post'),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card ───────────────────────────────────────────
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        child: Text(
                          '${widget.post.id}',
                          style: TextStyle(
                            fontSize: widget.post.id >= 100 ? 13 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Post #${widget.post.id}',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.person_rounded,
                                  size: 15, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                'User ${widget.post.userId}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Title card ────────────────────────────────────────────
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                          icon: Icons.title_rounded,
                          label: 'TITLE',
                          color: colorScheme.primary),
                      const SizedBox(height: 10),
                      Text(
                        widget.post.title,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Body card ─────────────────────────────────────────────
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(
                          icon: Icons.article_rounded,
                          label: 'BODY',
                          color: colorScheme.primary),
                      const Divider(height: 20),
                      Text(
                        widget.post.body,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.7,
                          color: Colors.grey.shade800,
                        ),
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
}

// ── Reusable section label ────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
        ),
      ],
    );
  }
}
