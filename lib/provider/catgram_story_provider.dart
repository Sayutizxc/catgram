import 'package:catgram/models/catgram_story_model.dart';
import 'package:faker/faker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cat_api_model.dart';
import '../repository/cat_repository.dart';
import 'general_provider.dart';

/// Mengambil data catgram post dari API
///
/// Mengembalikan data berupa List dari [CatgramStoryModel].
final catgramStoryProvider =
    Provider.family.autoDispose<Future<List<CatgramStoryModel>>, int>(
  (ref, page) async {
    final _faker = ref.read(fakerProvider);
    List<CatgramStoryModel> result = [];
    final _listCats =
        await ref.read(catRepositoryProvider).getCat(page: page, limit: 100);
    for (var cats in _listCats) {
      final catgramStory = _parseCatgram(faker: _faker, cats: cats);
      result.add(catgramStory);
    }
    return result;
  },
);

/// Memparse data catgram menjadi model [CatgramStoryModel].
///
CatgramStoryModel _parseCatgram(
    {required Faker faker, required List<CatModel> cats}) {
  final String _username = faker.internet.userName().replaceAll("-", "_");
  final String _profileImage =
      cats.last.url ?? "https://via.placeholder.com/1000";

  final catgramStory = CatgramStoryModel(
    username: _username,
    profileImage: _profileImage,
    stories: cats,
  );
  return catgramStory;
}
