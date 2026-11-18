
import 'package:hive/hive.dart';
import '../models/post.dart';

class FavoritesService {
  final Box<Post> favoritesBox =
      Hive.box<Post>('favoritesBox');

  Future<void> toggleFavorite(Post post) async {
    if (isFavorite(post.id)) {
      await favoritesBox.delete(post.id);
    } else {
      final copy = Post(
        id: post.id,
        userId: post.userId,
        title: post.title,
        body: post.body,
      );

      await favoritesBox.put(post.id, copy);
    }
  }

  bool isFavorite(int id) {
    return favoritesBox.containsKey(id);
  }

  List<Post> getFavorites() {
    return favoritesBox.values.toList();
  }
}
