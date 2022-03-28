import 'dart:math';

import 'package:catgram/models/catgram_model.dart';
import 'package:catgram/provider/catgram_post_provider.dart';
import 'package:catgram/provider/catgram_story_provider.dart';
import 'package:catgram/provider/general_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _postLoading = StateProvider<bool>((ref) {
  return false;
});

final _storyLoading = StateProvider<bool>((ref) {
  return false;
});

final homePageDataProvider =
    StateNotifierProvider<HomeNotifier, AsyncValue<Catgram>>((ref) {
  return HomeNotifier(ref)..initState();
});

class HomeNotifier extends StateNotifier<AsyncValue<Catgram>> {
  HomeNotifier(this._ref) : super(const AsyncLoading());
  final Ref _ref;

  Future<void> initState() async {
    final _randomStoryPage = Random().nextInt(5000) + 1;
    final _randomPostPage = Random().nextInt(5000) + 1;
    tryCatch(
      () async {
        final _stories =
            await _ref.read(catgramStoryProvider(_randomStoryPage));
        final _posts = await _ref.read(catgramPostProvider(_randomPostPage));
        final _catgram = Catgram(
          storyPage: _randomStoryPage,
          postPage: _randomPostPage,
          stories: _stories,
          posts: _posts,
        );
        state = AsyncData(_catgram);
      },
      showError: true,
    );
  }

  Future<void> loadMorePost() async {
    final _isLoading = _ref.read(_postLoading);
    if (_isLoading) return;

    state.whenData((_catgram) async {
      _ref.read(_postLoading.notifier).update((_) => true);

      await tryCatch(() async {
        final _newPosts =
            await _ref.read(catgramPostProvider(_catgram.postPage + 1));
        state = AsyncData(
          _catgram.copyWith(posts: [..._catgram.posts, ..._newPosts]),
        );
      });

      _ref.read(_postLoading.notifier).update((_) => false);
    });
  }

  Future<void> loadMoreStory() async {
    var _isLoading = _ref.read(_storyLoading);
    if (_isLoading) return;

    state.whenData((_catgram) async {
      _ref.read(_storyLoading.notifier).update((_) => true);

      await tryCatch(() async {
        final _newStories =
            await _ref.read(catgramStoryProvider(_catgram.storyPage + 1));
        state = AsyncData(
          _catgram.copyWith(stories: [..._catgram.stories, ..._newStories]),
        );
        // _ref.read(scaffoldKeyProvider).currentState?.clearSnackBars();
      });

      _ref.read(_storyLoading.notifier).update((_) => false);
    });
  }

  void removePost(String username, String profileImage) {
    state.whenData((_catgram) {
      _catgram.posts.removeWhere(
        (element) =>
            element.username == username &&
            element.profileImage == profileImage,
      );
      state = AsyncData(_catgram);
    });
  }

  void whenError(Object err, [bool showError = false]) {
    final errorMessage = err.toString().replaceAll("Exception: ", "");
    _ref.read(scaffoldKeyProvider).currentState?.clearSnackBars();
    final SnackBar snackBar = SnackBar(
      content: Text(
        errorMessage,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
      dismissDirection: DismissDirection.horizontal,
    );
    _ref.read(scaffoldKeyProvider).currentState?.showSnackBar(snackBar);
    if (showError) {
      state = AsyncError(errorMessage);
    }
  }

  Future<void> tryCatch(Future Function() doSomething,
      {bool showError = false}) async {
    try {
      await doSomething();
    } catch (err) {
      whenError(err, showError);
    }
  }
}
