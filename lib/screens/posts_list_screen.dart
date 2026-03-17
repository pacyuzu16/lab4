import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/exceptions.dart';
import '../utils/snack_helper.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class PostsListScreen extends StatefulWidget {
  const PostsListScreen({super.key});

  @override
  State<PostsListScreen> createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = _apiService.getPosts();
  }

  // Returns the future so RefreshIndicator can properly await it.
  Future<void> _refresh() {
    setState(() => _postsFuture = _apiService.getPosts());
    return _postsFuture;
  }

  Future<void> _deletePost(int id) async {
    try {
      await _apiService.deletePost(id);
      if (mounted) {
        showSuccessSnackBar(context, 'Post deleted successfully');
        _refresh();
      }
    } catch (e) {
      if (mounted) showErrorSnackBar(context, 'Error: $e');
    }
  }

  void _confirmDelete(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Delete Post'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete\n"${post.title}"?',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deletePost(post.id);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Navigates to [screen] and refreshes the list only if changes were made.
  Future<void> _navigateAndRefresh(Widget screen) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (changed == true) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Posts Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          // ── Loading ──────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading posts...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          // ── Error ────────────────────────────────────────────────────
          if (snapshot.hasError) {
            final isNoInternet = snapshot.error is NoInternetException;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isNoInternet
                            ? Colors.orange.shade50
                            : Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isNoInternet
                            ? Icons.wifi_off_rounded
                            : Icons.cloud_off_rounded,
                        size: 64,
                        color: isNoInternet
                            ? Colors.orange.shade400
                            : Colors.red.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isNoInternet
                          ? 'No Internet Connection'
                          : 'Something went wrong',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isNoInternet
                          ? 'Please check your Wi-Fi or mobile data\nand try again.'
                          : '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Data ─────────────────────────────────────────────────────
          final posts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: Column(
              children: [
                // Post count banner
                Container(
                  width: double.infinity,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Text(
                    '${posts.length} posts loaded  •  Pull down to refresh',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Posts list
                Expanded(
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _PostCard(
                        post: post,
                        onTap: () =>
                            _navigateAndRefresh(PostDetailScreen(post: post)),
                        onEdit: () =>
                            _navigateAndRefresh(PostFormScreen(post: post)),
                        onDelete: () => _confirmDelete(context, post),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefresh(const PostFormScreen()),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Post'),
      ),
    );
  }
}

// ── Post Card widget ──────────────────────────────────────────────────────────
class _PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ID badge
              CircleAvatar(
                radius: 22,
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                child: Text(
                  '${post.id}',
                  style: TextStyle(
                    fontSize: post.id >= 100 ? 11 : 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title + body preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Action buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_rounded,
                        color: Colors.orange.shade600, size: 20),
                    tooltip: 'Edit',
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_rounded,
                        color: Colors.red.shade400, size: 20),
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
