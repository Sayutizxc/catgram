import 'package:flutter/foundation.dart';

import 'package:catgram/models/cat_api_model.dart';

class CatgramPostModel {
  String username;
  String profileImage;
  List<CatModel> posts;
  bool isLiked;
  int likedNumber;
  CatgramPostModel({
    required this.username,
    required this.profileImage,
    required this.posts,
    this.isLiked = false,
    required this.likedNumber,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CatgramPostModel &&
        other.username == username &&
        other.profileImage == profileImage &&
        listEquals(other.posts, posts) &&
        other.isLiked == isLiked &&
        other.likedNumber == likedNumber;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        profileImage.hashCode ^
        posts.hashCode ^
        isLiked.hashCode ^
        likedNumber.hashCode;
  }
}
