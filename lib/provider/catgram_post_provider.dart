import 'dart:math';

import 'package:faker/faker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cat_api_model.dart';
import '../models/catgram_post_model.dart';
import '../repository/cat_repository.dart';
import 'general_provider.dart';

/// Mengambil data catgram post dari API
///
/// Mengembalikan data berupa List dari [CatgramPostModel].
final catgramPostProvider =
    Provider.family.autoDispose<Future<List<CatgramPostModel>>, int>(
  (ref, page) async {
    final _faker = ref.read(fakerProvider);
    List<CatgramPostModel> result = [];
    final _listCats =
        await ref.read(catRepositoryProvider).getCat(page: page, limit: 100);
    for (var cats in _listCats) {
      final catgramPost = _parseCatgram(faker: _faker, cats: cats);
      result.add(catgramPost);
    }
    return result;
  },
);

/// Memparse data catgram menjadi model [CatgramPostModel].
///
CatgramPostModel _parseCatgram(
    {required Faker faker, required List<CatModel> cats}) {
  final String _username = faker.internet.userName().replaceAll("-", "_");
  final int _likedNumber = Random().nextInt(100000);
  final String _profileImage =
      cats.last.url ?? "https://via.placeholder.com/1000";

  final catgramPost = CatgramPostModel(
    username: _username,
    profileImage: _profileImage,
    posts: cats,
    likedNumber: _likedNumber,
  );
  return catgramPost;
}
