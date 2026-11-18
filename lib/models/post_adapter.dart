
import 'package:hive/hive.dart';
import 'post.dart';

class PostAdapter extends TypeAdapter<Post> {
  @override
  final int typeId = 0;

  @override
  Post read(BinaryReader reader) {
    return Post(
      id: reader.readInt(),
      userId: reader.readInt(),
      title: reader.readString(),
      body: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, Post obj) {
    writer.writeInt(obj.id);
    writer.writeInt(obj.userId);
    writer.writeString(obj.title);
    writer.writeString(obj.body);
  }
}
