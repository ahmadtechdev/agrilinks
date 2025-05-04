import 'package:cloud_firestore/cloud_firestore.dart';

class NewsFeedModel {
  final String id;
  final String userId;
  final String postTitle;
  final String post;
  final int likes;
  final DateTime createdAt;
  final List<String> likedBy;
  final String? imageUrl;
  final String? username;
  final String? userPhotoUrl;

  NewsFeedModel({
    required this.id,
    required this.userId,
    required this.postTitle,
    required this.post,
    required this.likes,
    required this.createdAt,
    required this.likedBy,
    this.imageUrl,
    this.username,
    this.userPhotoUrl,
  });

  factory NewsFeedModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NewsFeedModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      postTitle: data['postTitle'] ?? '',
      post: data['post'] ?? '',
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      imageUrl: data['imageUrl']?? '',
      username: data['username']??'',
      userPhotoUrl: data['userPhotoUrl']??'',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'postTitle': postTitle,
      'post': post,
      'likes': likes,
      'createdAt': createdAt,
      'likedBy': likedBy,
      'imageUrl': imageUrl,
      'username': username,
      'userPhotoUrl': userPhotoUrl,
    };
  }

  NewsFeedModel copyWith({
    String? id,
    String? userId,
    String? postTitle,
    String? post,
    int? likes,
    DateTime? createdAt,
    List<String>? likedBy,
    String? imageUrl,
    String? username,
    String? userPhotoUrl,
  }) {
    return NewsFeedModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      postTitle: postTitle ?? this.postTitle,
      post: post ?? this.post,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      imageUrl: imageUrl ?? this.imageUrl,
      username: username ?? this.username,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
    );
  }
}