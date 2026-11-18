
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/post.dart';
import '../services/post_service.dart';
import '../services/favorites_service.dart';
import 'favorites_screen.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final PostService _postService = PostService();
  final FavoritesService _favoritesService = FavoritesService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _postService.getPosts();
    } catch (e) {
      _errorMessage = 'Unable to load posts. Check your connection.';
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Favorites',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadPosts,
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Post>>(
        valueListenable:
            Hive.box<Post>('favoritesBox').listenable(),
        builder: (context, favoritesBox, child) {
          final posts = Hive.box<Post>('postsBox').values.toList();

          if (_isLoading && posts.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (posts.isEmpty && _errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadPosts,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (posts.isEmpty) {
            return const Center(
              child: Text('No posts available.'),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              final isFavorite =
                  _favoritesService.isFavorite(post.id);

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              color: isFavorite
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              await _favoritesService
                                  .toggleFavorite(post);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(post.body),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
