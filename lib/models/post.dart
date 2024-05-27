import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final Timestamp createdAt;
  final String imageUrl;

  Post({
    required this.id,
    required this.createdAt,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "createdAt": createdAt,
      "imageUrl": imageUrl,
    };
  }

  static Post fromJson(Map<String, dynamic> json) => Post(
        id: json["id"],
        createdAt: json["createdAt"],
        imageUrl: json["imageUrl"],
      );
}
