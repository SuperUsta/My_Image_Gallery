import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_gallery/models/post.dart';

class PostsApi {
  static Future delete(String postId) async {
    final postRef = FirebaseFirestore.instance.collection("Posts").doc(postId);
    postRef.delete();
  }

  static Stream<List<Post>> readPosts() => FirebaseFirestore.instance
      .collection("Posts")
      .orderBy("createdAt", descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((e) => Post.fromJson(e.data())).toList());

  static Future createPost(Post post) async {
    final postRef = FirebaseFirestore.instance.collection("Posts").doc(post.id);

    final json = post.toJson();
    postRef.set(json);
  }
}
