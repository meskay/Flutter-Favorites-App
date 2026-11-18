
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/post.dart';

class PostService {
  Future<List<Post>> getPosts() async {
    final postsBox = Hive.box<Post>('postsBox');

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://jsonplaceholder.typicode.com/posts',
            ),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final posts = data.map((item) {
          return Post(
            id: item['id'],
            userId: item['userId'],
            title: item['title'],
            body: item['body'],
          );
        }).toList();

        await postsBox.clear();

        for (final post in posts) {
          await postsBox.put(post.id, post);
        }

        return posts;
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      // Return previously cached posts when offline.
      if (postsBox.isNotEmpty) {
        return postsBox.values.toList();
      }

      rethrow;
    }
  }
}
