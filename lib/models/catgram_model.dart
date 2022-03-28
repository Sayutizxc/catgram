import 'package:flutter/foundation.dart';

import 'package:catgram/models/catgram_post_model.dart';
import 'package:catgram/models/catgram_story_model.dart';

class Catgram {
  final int storyPage;
  final int postPage;
  final List<CatgramStoryModel> stories;
  final List<CatgramPostModel> posts;
  Catgram({
    required this.storyPage,
    required this.postPage,
    required this.stories,
    required this.posts,
  });

  Catgram copyWith({
    int? storyPage,
    int? postPage,
    List<CatgramStoryModel>? stories,
    List<CatgramPostModel>? posts,
  }) {
    return Catgram(
      storyPage: storyPage ?? this.storyPage,
      postPage: postPage ?? this.postPage,
      stories: stories ?? this.stories,
      posts: posts ?? this.posts,
    );
  }

  @override
  String toString() {
    return 'Catgram(storyPage: $storyPage, postPage: $postPage, stories: $stories, posts: $posts)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Catgram &&
        other.storyPage == storyPage &&
        other.postPage == postPage &&
        listEquals(other.stories, stories) &&
        listEquals(other.posts, posts);
  }

  @override
  int get hashCode {
    return storyPage.hashCode ^
        postPage.hashCode ^
        stories.hashCode ^
        posts.hashCode;
  }
}
