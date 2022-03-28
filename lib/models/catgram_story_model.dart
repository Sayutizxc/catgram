import 'package:flutter/foundation.dart';

import 'package:catgram/models/cat_api_model.dart';

class CatgramStoryModel {
  String username;
  String profileImage;
  List<CatModel> stories;
  CatgramStoryModel({
    required this.username,
    required this.profileImage,
    required this.stories,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CatgramStoryModel &&
        other.username == username &&
        other.profileImage == profileImage &&
        listEquals(other.stories, stories);
  }

  @override
  int get hashCode {
    return username.hashCode ^ profileImage.hashCode ^ stories.hashCode;
  }
}
